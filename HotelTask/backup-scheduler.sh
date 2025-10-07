#!/bin/bash
set -e

echo "[INFO] Setting up cron jobs for backup scheduler..."

cat > /etc/cron.d/mysql-backup << 'EOF'
# MySQL Backup Cron Jobs
# Format: minute hour day month weekday command

# Daily incremental backup at 09:07
07 09 * * * root /scripts/backup_incremental.sh >> /var/log/backup-incremental.log 2>&1

# Weekly merge every Sunday at 00:10
10 0 * * 0 root /scripts/merge_weekly.sh >> /var/log/backup-weekly.log 2>&1

EOF

chmod 0644 /etc/cron.d/mysql-backup

mkdir -p /var/log
touch /var/log/backup-incremental.log
touch /var/log/backup-weekly.log

echo "[INFO] Cron jobs installed successfully!"
echo "[INFO] Schedule:"
echo "  - Daily incremental: 09:07 every day"
echo "  - Weekly merge: Sunday 00:10"

echo "[INFO] Starting cron daemon..."
cron -f