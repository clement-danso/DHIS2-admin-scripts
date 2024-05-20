#!/bin/bash
#       ____  __  ______________
#      / __ \/ / / /  _/ ___/__ \
#     / / / / /_/ // / \__ \__/ /
#    / /_/ / __  // / ___/ / __/
#   /_____/_/ /_/___//____/____/
#
set -e

# Check if both arguments are provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <gzip-compressed-dump-file> <database-name>"
  exit 1
fi

# Assign the arguments to variables
DUMP_FILE=$1
DB_NAME=$2

# Check if the dump file exists
if [ ! -f "$DUMP_FILE" ]; then
  echo "Error: Dump file '$DUMP_FILE' not found."
  exit 1
fi

# Database connection parameters
LXC_CONTAINER_NAME="postgres"  # Replace with your LXC container name
DB_USER="root"
#DB_PASSWORD="your_password"



# Check if the provided database name exists inside the LXC container
lxc exec "$LXC_CONTAINER_NAME" -- sh -c "psql -U $DB_USER -d $DB_NAME -lqt | cut -d \| -f 1 | grep -qw $DB_NAME"
if [ $? -ne 0 ]; then
  echo "Error: Database '$DB_NAME' does not exist inside the container."
  exit 1
fi

# Search for active connections to the database
#ACTIVE_CONNECTIONS=$(lxc exec $LXC_CONTAINER_NAME -- sh -c "psql -U $DB_USER -d $DB_NAME -t -c 'SELECT pg_terminate_backend (pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = \"$DB_NAME\" AND pid <> pg_backend_pid();'")
#lxc exec $LXC_CONTAINER_NAME -- sh -c "psql -U $DB_USER -c 'SELECT pg_terminate_backend (pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = \"$DB_NAME\"'"

# If there are active connections, terminate them
if [[ -n "$ACTIVE_CONNECTIONS" ]]; then
    echo "Terminating active connections to the database..."
#    lxc exec $LXC_CONTAINER_NAME -- sh -c "psql -U $DB_USER -d $DB_NAME -c 'SELECT pg_terminate_backend (pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = \"$DB_NAME\" AND pid <> pg_backend_pid();'"
    lxc exec $LXC_CONTAINER_NAME -- sh -c "psql -U $DB_USER -c 'SELECT pg_terminate_backend (pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = \"$DB_NAME\"'"

fi

# Drop the existing database
lxc exec "$LXC_CONTAINER_NAME" -- sh -c "dropdb $DB_NAME"

# Create a new database with the same name
lxc exec "$LXC_CONTAINER_NAME" -- sh -c "createdb -O $DB_NAME $DB_NAME"

# Restore the database using the gzip-compressed dump file and provided database name inside the LXC container
#lxc exec "$LXC_CONTAINER_NAME" -- sh -c "gunzip -c $DUMP_FILE | psql -U $DB_USER -d $DB_NAME"
zcat $DUMP_FILE | grep -v 'ALTER .* OWNER' |sudo lxc exec postgres -- psql $DB_NAME


# Check the exit status of the psql command
if [ $? -eq 0 ]; then
  echo "Database restore from '$DUMP_FILE' to '$DB_NAME' completed successfully."
else
  echo "Error: Database restore to '$DB_NAME' failed."
fi

echo "REASSIGN OWNED BY root TO $DB_NAME" | sudo lxc exec postgres -- psql $DB_NAME
