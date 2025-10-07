#!/bin/bash
set -e

echo "[INFO] Merging 7 daily incrementals into weekly backup..."

DATE=$(date +%F_%H-%M-%S)

INCREMENTALS=($(ls -dt /backups/inc_* 2>/dev/null | head -7 | sort))

if [ ${#INCREMENTALS[@]} -lt 7 ]; then
    echo "[ERROR] Found only ${#INCREMENTALS[@]} incrementals, need 7 for weekly merge!"
    echo "[INFO] Skipping weekly merge this time."
    exit 1
fi

FIRST_INC="${INCREMENTALS[0]}"
echo "[INFO] Checking base for first incremental: $FIRST_INC"

BASE_FROM_META=$(grep "incremental_basedir" "$FIRST_INC/xtrabackup_checkpoints" | cut -d'=' -f2 | tr -d ' ')

if [ -z "$BASE_FROM_META" ] || [ ! -d "$BASE_FROM_META" ]; then
    echo "[ERROR] Cannot find base backup: $BASE_FROM_META"
    echo "[INFO] Looking for latest full or weekly backup..."
    BASE=$(ls -dt /backups/full_* /backups/weekly_* 2>/dev/null | head -1)
    if [ -z "$BASE" ]; then
        echo "[ERROR] No base backup found!"
        exit 1
    fi
else
    BASE="$BASE_FROM_META"
fi

echo "[INFO] Using base backup: $BASE"

TARGET=/backups/weekly_$DATE
mkdir -p "$TARGET"

echo "[INFO] Found ${#INCREMENTALS[@]} incrementals to merge"
echo "[INFO] Creating weekly backup: $TARGET"

echo "[INFO] Copying base backup..."
cp -a "$BASE/." "$TARGET/"

echo "[INFO] Preparing base backup..."
xtrabackup --prepare --apply-log-only --target-dir="$TARGET"

for ((i=0; i<${#INCREMENTALS[@]}; i++)); do
    INC="${INCREMENTALS[$i]}"
    echo "[INFO] Applying incremental $((i+1))/7: $INC"
    
    if ! xtrabackup --prepare --apply-log-only --target-dir="$TARGET" --incremental-dir="$INC"; then
        echo "[ERROR] Failed to apply: $INC"
        echo "[INFO] This incremental might not chain properly. Check LSN values."
        exit 1
    fi
done

echo "[INFO] Performing final prepare..."
xtrabackup --prepare --target-dir="$TARGET"

echo "[INFO] Weekly backup created successfully: $TARGET"

echo "[INFO] Removing the 7 applied incrementals..."
for INC in "${INCREMENTALS[@]}"; do
    echo "[INFO] Deleting: $INC"
    rm -rf "$INC"
done

echo "[INFO] Removing old base backup: $BASE"
if [ -d "$BASE" ]; then
    rm -rf "$BASE"
    echo "[INFO] Old base deleted: $BASE"
else
    echo "[WARNING] Base backup already removed or not found"
fi

echo "[INFO] Weekly merge completed successfully!"
echo "[INFO] Weekly backup contains: base + 7 incrementals merged"
echo "[INFO] Old base and incrementals have been cleaned up"