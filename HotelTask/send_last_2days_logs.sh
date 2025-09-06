
LOG_FOLDER="./storage/logs"

TMP_FOLDER="./storage/tmp_logs"
mkdir -p "$TMP_FOLDER"

rm -f "$TMP_FOLDER"/*.log

find "$LOG_FOLDER" -type f -name "*.log" -mtime -1 -exec cp {} "$TMP_FOLDER" \;

echo "Filtered logs from last day(s) copied to $TMP_FOLDER"

docker-compose restart promtail
