#!/bin/bash

# Configuration
DB_HOST="mysql-primary"
DB_PORT="3306"
DB_USER="root"
DB_PASS="rootpassword"
DB_NAME="hoteldb"
TABLE_NAME="your_table_name" 

LOG_FILE="/archive-logs/archive-$(date +%Y%m%d-%H%M%S).log"

echo "=== Starting Archive Process at $(date) ===" | tee -a $LOG_FILE

if ! mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e "SELECT 1" > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to database" | tee -a $LOG_FILE
    exit 1
fi

echo "Database connection successful" | tee -a $LOG_FILE

echo "Starting pt-archiver..." | tee -a $LOG_FILE

pt-archiver \
  --source h=$DB_HOST,P=$DB_PORT,D=$DB_NAME,t=$TABLE_NAME,u=$DB_USER,p=$DB_PASS \
  --where "created_at < NOW() - INTERVAL 90 DAY" \
  --limit 1000 \
  --commit-each \
  --purge \
  --progress 5000 \
  --statistics 2>&1 | tee -a $LOG_FILE

if [ $? -eq 0 ]; then
    echo "Archiving completed successfully" | tee -a $LOG_FILE
    
    echo "Starting OPTIMIZE TABLE..." | tee -a $LOG_FILE
    
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e "OPTIMIZE TABLE $DB_NAME.$TABLE_NAME" 2>&1 | tee -a $LOG_FILE
    
    if [ $? -eq 0 ]; then
        echo "OPTIMIZE TABLE completed successfully" | tee -a $LOG_FILE
    else
        echo "WARNING: OPTIMIZE TABLE failed" | tee -a $LOG_FILE
    fi
else
    echo "ERROR: Archiving failed" | tee -a $LOG_FILE
    exit 1
fi

echo "=== Archive Process Completed at $(date) ===" | tee -a $LOG_FILE
echo "" | tee -a $LOG_FILE