#!/bin/bash

# Database credentials
#LXC_CONTAINER="dw"
DB_NAME="dw"
DB_USER="root"
#DB_PASSWORD="your_database_password"


# Log file path
LOG_FILE="/home/quoda/adminlogs/dailybackup.log"
#S3 Storage log file
S3_STORAGE_LOG_FILE="/home/quoda/adminlogs/dailys3upload.log"
# Get the current timestamp for s3storage log
timestamp=$(date +"%Y-%m-%d %H:%M:%S")


# Function to log messages
log_message() {
    local message="$1"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$timestamp] - $message" >> "$LOG_FILE"
}



# Function to pull a file and replace it if it already exists
pull_and_replace_file() {
    local source_file="/home/ubuntu/backups/$BACKUP_FILE"
    local destination_file="/home/quoda/prod_backups/$BACKUP_FILE"

    # Check if the destination file exists
    if [ -f "$destination_file" ]; then
        echo "Replacing existing file: $destination_file"
    else
        # Pull the file if the destination file does not exist
        lxc file pull "postgres$source_file" "$destination_file"
        if [ $? -eq 0 ]; then
            echo "File pulled successfully to: $destination_file"
        else
            echo "Failed to pull the file!"
        fi
    fi
}


# Set the backup directory and filename
BACKUP_DIR="/home/ubuntu/backups"
BACKUP_FILE="asbcdb_backup_$(date +'%Y%m%d%H%M%S').sql"

# Run the pg_dump command to create the backup

lxc exec postgres -- pg_dump -U root -d dw -f /home/ubuntu/backups/$BACKUP_FILE


# Check if the backup was successful
if [ $? -eq 0 ]; then
    echo "Database backup file created! File saved as: $BACKUP_DIR/$BACKUP_FILE"
    log_message "Database backup file created!. File saved as: $BACKUP_DIR/$BACKUP_FILE"
else
    echo "Database backup failed!"
    log_message "Database backup failed!"
fi



# Compress the SQL dump file using gzip
lxc exec postgres -- gzip /home/ubuntu/backups/$BACKUP_FILE




# Call the pull_and_replace_file function to pull and replace the backup file
#pull_and_replace_file
#Push backup file from /home/ubuntu/backups to the linode s3 storage
lxc exec postgres -- su - ubuntu -c " linode-cli obj put /home/ubuntu/backups/"$BACKUP_FILE.gz" asbc-backups"


# Check the exit status of the Linode CLI command
if [ $? -eq 0 ]; then
    echo "[$timestamp] Saved to S3 storage" >> $S3_STORAGE_LOG_FILE
else
    echo "[$timestamp] Failed to save to S3 storage: $output" >> $S3_STORAGE_LOG_FILE
fi
