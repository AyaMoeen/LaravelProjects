#!/bin/sh
set -eu

# --- CONFIG ---
PRIMARY_HOST="mysql-primary"
SECONDARY_HOST="mysql-secondary"
MYSQL_USER="root"
MYSQL_PASS="${MYSQL_ROOT_PASSWORD:-rootpassword}"
CHECK_INTERVAL=5
FAIL_THRESHOLD=3
PROMOTED_FLAG="/var/run/mysql_promoted.flag"
LOG_FILE="/var/log/mysql_failover.log"
REPLAY_LOG="/var/log/mysql_secondary_queries.log"
MAX_REPLICATION_WAIT=60
# --------------

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

is_up() {
  mysqladmin ping -h"$1" -u"$MYSQL_USER" -p"$MYSQL_PASS" --connect-timeout=3 --silent > /dev/null 2>&1
}

run_on() {
  local host="$1"; shift
  mysql -h"$host" -u"$MYSQL_USER" -p"$MYSQL_PASS" -e "$*" 2>/dev/null
}

promote_secondary() {
  log "PROMOTION: Starting promotion of $SECONDARY_HOST"
  run_on "$SECONDARY_HOST" "STOP REPLICA;"
  run_on "$SECONDARY_HOST" "SET GLOBAL super_read_only=OFF; SET GLOBAL read_only=OFF;"
  touch "$PROMOTED_FLAG"
  log "PROMOTION: $SECONDARY_HOST is now writable (promoted)"
}

replay_log_to_primary() {
  if [ -f "$REPLAY_LOG" ]; then
    log "Replaying changes from secondary to primary..."
    mysql -h"$PRIMARY_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASS" < "$REPLAY_LOG" 2>>"$LOG_FILE"
    log "Replay complete"
    mv "$REPLAY_LOG" "${REPLAY_LOG}.replayed.$(date +%s)"
  else
    log "No replay log found"
  fi
}

skip_gtid_conflict() {
  local host="$1"
  local errno="$2"
  local gtid="$3"
  if [ -n "$gtid" ]; then
    log "GTID conflict on $host — skipping GTID $gtid (errno $errno)"
    run_on "$host" "STOP REPLICA;"
    run_on "$host" "SET GTID_NEXT='$gtid'; BEGIN; COMMIT; SET GTID_NEXT='AUTOMATIC';"
    run_on "$host" "START REPLICA;"
  fi
}

# --- MAIN LOOP ---
fail_count=0
log "Watchdog started (check every ${CHECK_INTERVAL}s, threshold ${FAIL_THRESHOLD})"

while true; do
  if is_up "$PRIMARY_HOST"; then
    fail_count=0
    if [ -f "$PROMOTED_FLAG" ]; then
      log "Primary is back → syncing from promoted secondary"

      # Step 1: Reconfigure primary to follow secondary
      run_on "$PRIMARY_HOST" "STOP REPLICA;"
      run_on "$PRIMARY_HOST" "RESET REPLICA ALL;"
      run_on "$PRIMARY_HOST" "SET GLOBAL super_read_only=ON; SET GLOBAL read_only=ON;"
      run_on "$SECONDARY_HOST" "SET GLOBAL super_read_only=OFF; SET GLOBAL read_only=OFF;"
      run_on "$PRIMARY_HOST" "CHANGE REPLICATION SOURCE TO SOURCE_HOST='$SECONDARY_HOST', SOURCE_USER='replicator', SOURCE_PASSWORD='replica_pass', SOURCE_AUTO_POSITION=1;"
      run_on "$PRIMARY_HOST" "START REPLICA;"

      # Step 2: Handle GTID conflicts on primary until replication resumes
      while true; do
        replica_status=$(run_on "$PRIMARY_HOST" "SHOW REPLICA STATUS\G")
        sql_running=$(echo "$replica_status" | grep 'Replica_SQL_Running:' | awk '{print $2}')
        last_errno=$(echo "$replica_status" | grep 'Last_SQL_Errno:' | awk '{print $2}')
        last_gtid=$(echo "$replica_status" | grep 'Retrieved_Gtid_Set:' | awk '{print $2}')

        if [ "$sql_running" = "Yes" ]; then
          log "Replication SQL thread is running — no GTID conflict"
          break
        fi

        if [ "$last_errno" = "1062" ] || [ "$last_errno" = "1396" ]; then
          skip_gtid_conflict "$PRIMARY_HOST" "$last_errno" "$last_gtid"
        else
          log "Unhandled replication error on $PRIMARY_HOST — errno $last_errno"
          break
        fi
      done

      log "$PRIMARY_HOST is now replicating from $SECONDARY_HOST"

      # Step 3: Wait for replication to catch up
      log "Waiting for replication to catch up before promoting $PRIMARY_HOST..."
      attempt=0
      while true; do
        replica_status=$(run_on "$PRIMARY_HOST" "SHOW REPLICA STATUS\G")
        sql_running=$(echo "$replica_status" | grep 'Replica_SQL_Running:' | awk '{print $2}')
        io_running=$(echo "$replica_status" | grep 'Replica_IO_Running:' | awk '{print $2}')
        seconds_behind=$(echo "$replica_status" | grep 'Seconds_Behind_Master:' | awk '{print $2}')

        if [ "$sql_running" != "Yes" ] || [ "$io_running" != "Yes" ]; then
          log "Replication not running — exiting wait loop"
          break
        fi
        if [ "$seconds_behind" = "0" ]; then
          log "Replication caught up (Seconds_Behind_Master = 0)"
          break
        fi
        attempt=$((attempt+1))
        if [ "$attempt" -ge "$MAX_REPLICATION_WAIT" ]; then
          log "Timeout waiting for replication — continuing"
          break
        fi
        log "Replication lag: ${seconds_behind:-unknown} seconds — waiting..."
        sleep 5
      done

      # Step 4: Replay changes from secondary to primary
      replay_log_to_primary

      # Step 5: Promote primary back to master
      run_on "$PRIMARY_HOST" "STOP REPLICA;"
      run_on "$PRIMARY_HOST" "SET GLOBAL super_read_only=OFF; SET GLOBAL read_only=OFF;"
      run_on "$SECONDARY_HOST" "SET GLOBAL super_read_only=ON; SET GLOBAL read_only=ON;"
      log "$PRIMARY_HOST is now writable again"

      # Step 6: Reconfigure secondary to follow primary
      run_on "$SECONDARY_HOST" "STOP REPLICA;"
      run_on "$SECONDARY_HOST" "RESET REPLICA ALL;"
      run_on "$SECONDARY_HOST" "CHANGE REPLICATION SOURCE TO SOURCE_HOST='$PRIMARY_HOST', SOURCE_USER='replicator', SOURCE_PASSWORD='replica_pass', SOURCE_AUTO_POSITION=1;"
      run_on "$SECONDARY_HOST" "START REPLICA;"

      # Step 7: Handle GTID conflict on secondary
      while true; do
        replica_status=$(run_on "$SECONDARY_HOST" "SHOW REPLICA STATUS\G")
        sql_running=$(echo "$replica_status" | grep 'Replica_SQL_Running:' | awk '{print $2}')
        last_errno=$(echo "$replica_status" | grep 'Last_SQL_Errno:' | awk '{print $2}')
        last_gtid=$(echo "$replica_status" | grep 'Retrieved_Gtid_Set:' | awk '{print $2}')

        if [ "$sql_running" = "Yes" ]; then
          log "Secondary replication SQL thread is running — no GTID conflict"
          break
        fi

        if [ "$last_errno" = "1062" ] || [ "$last_errno" = "1396" ]; then
          skip_gtid_conflict "$SECONDARY_HOST" "$last_errno" "$last_gtid"
        else
          log "Unhandled replication error on $SECONDARY_HOST — errno $last_errno"
          break
        fi
      done

      log "$SECONDARY_HOST is now read-only and replicating from $PRIMARY_HOST"

      # Step 8: Clear promotion flag
      rm -f "$PROMOTED_FLAG"
    fi
  else
    fail_count=$((fail_count+1))
    log "Primary unreachable (count=$fail_count/$FAIL_THRESHOLD)"
    if [ "$fail_count" -ge "$FAIL_THRESHOLD" ] && [ ! -f "$PROMOTED_FLAG" ]; then
      log "Threshold reached → promoting $SECONDARY_HOST"
      promote_secondary
    fi
  fi
  sleep "$CHECK_INTERVAL"
done
