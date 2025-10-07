#!/bin/bash
set -e

echo "[INFO] Running FULL backup..."
DATE=$(date +%F_%H-%M-%S)
TARGET=/backups/full_$DATE
mkdir -p "$TARGET"

xtrabackup --backup \
          --target-dir="$TARGET" \
          --datadir=/var/lib/mysql \
          --user=root \
          --password=rootpassword \
          --host=mysql-secondary

xtrabackup --prepare --apply-log-only --target-dir="$TARGET"

echo "[INFO] Full backup completed: $TARGET"