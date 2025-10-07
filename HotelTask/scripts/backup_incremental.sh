
#!/bin/bash
set -e

echo "[INFO] Running INCREMENTAL backup..."
DATE=$(date +%F_%H-%M-%S)

BASE=$(ls -dt /backups/full_* /backups/weekly_* /backups/inc_* 2>/dev/null | head -1)
if [ -z "$BASE" ]; then
    echo "[ERROR] No base backup found. Please run full backup first."
    exit 1
fi

TARGET=/backups/inc_$DATE
mkdir -p "$TARGET"

echo "[INFO] Using base: $BASE"
xtrabackup --backup \
          --target-dir="$TARGET" \
          --incremental-basedir="$BASE" \
          --datadir=/var/lib/mysql \
          --user=root \
          --password=rootpassword \
          --host=mysql-secondary

echo "[INFO] Incremental backup completed: $TARGET"