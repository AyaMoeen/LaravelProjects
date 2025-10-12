#!/bin/bash
set -e

echo "Starting Backup and Archive Scheduler..."

mkdir -p /var/log /backups /archive-logs
touch /var/log/backup-incremental.log
touch /var/log/backup-weekly.log
touch /backups/backup.log 
touch /archive-logs/archive-main.log  

cat > /etc/cron.d/mysql-tasks << 'EOF'
# MySQL Backup Cron Jobs
# Format: minute hour day month weekday command

# Daily incremental backup at 23:59
59 23 * * * root /scripts/backup_incremental.sh >> /var/log/backup-incremental.log 2>&1

# Weekly merge every Sunday at 00:10
10 0 * * 0 root /scripts/merge_weekly.sh >> /var/log/backup-weekly.log 2>&1

# Archive old data every day at 00:20 AM (after backup completes)
20 0 * * * root /scripts/archive-old-data.sh >> /archive-logs/archive-main.log 2>&1

EOF

chmod 0644 /etc/cron.d/mysql-tasks

echo "Cron scheduler started. Tasks scheduled:"
echo "- Backup: Daily at 23:59 PM"
echo "- Backup: weekly at 00:10 AM"
echo "- Archive: Daily at 00:20 AM"
echo ""

cron && tail -f /var/log/backup-incremental.log /var/log/backup-weekly.log /archive-logs/archive-main.log