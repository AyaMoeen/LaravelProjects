#!/bin/bash
set -e

echo "[INFO] Starting backup restoration..."

if [ -z "$1" ]; then
    echo "[ERROR] Please specify backup path"
    echo "Usage: $0 /backups/full_YYYY-MM-DD_HH-MM-SS"
    exit 1
fi

BACKUP_PATH=$1

if [ ! -d "$BACKUP_PATH" ]; then
    echo "[ERROR] Backup directory not found: $BACKUP_PATH"
    exit 1
fi

echo "[INFO] Restoring from: $BACKUP_PATH"

echo "[INFO] Stopping MySQL in restore container..."
docker-compose stop mysql-restore

echo "[INFO] Cleaning existing data..."
docker-compose exec mysql-restore sh -c "rm -rf /var/lib/mysql/*"

echo "[INFO] Performing restoration..."
docker exec mysql-backup bash -c "
    xtrabackup --copy-back \
              --target-dir=$BACKUP_PATH \
              --datadir=/var/lib/mysql
"

echo "[INFO] Fixing file permissions..."
docker-compose exec mysql-restore sh -c "chown -R mysql:mysql /var/lib/mysql"

echo "[INFO] Starting MySQL restore container..."
docker-compose start mysql-restore

echo "[INFO] Waiting for MySQL to start..."
sleep 30

echo "[INFO] Verifying restoration..."
mysql -h 127.0.0.1 -P 3310 -uroot -prootpassword -e "SHOW DATABASES;"

echo "[SUCCESS] Backup restoration completed!"