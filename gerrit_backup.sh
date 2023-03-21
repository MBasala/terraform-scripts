#!/bin/sh

# Check if this is the first run
if [ ! -f ${FIRST_RUN_MARKER} ]; then
  exit 0
fi

# Set variables
REMOTE_GERRIT_USER=${REMOTE_GERRIT_USER:-user}
REMOTE_GERRIT_HOST=${REMOTE_GERRIT_HOST:-example.com}
REMOTE_GERRIT_PORT=${REMOTE_GERRIT_PORT:-29418}
REMOTE_GERRIT_PATH=${REMOTE_GERRIT_PATH:-/path/to/remote/gerrit}
LOCAL_GERRIT_BACKUP_PATH=${LOCAL_GERRIT_BACKUP_PATH:-/path/to/local/backup}
REMOTE_DB_NAME=${REMOTE_DB_NAME:-gerrit_db}
LOCAL_DB_NAME=${LOCAL_DB_NAME:-gerrit_db}

# Stop Gerrit on the remote server
ssh -p ${REMOTE_GERRIT_PORT} ${REMOTE_GERRIT_USER}@${REMOTE_GERRIT_HOST} "gerrit.sh stop"

# Create a backup of the Gerrit server data
ssh -p ${REMOTE_GERRIT_PORT} ${REMOTE_GERRIT_USER}@${REMOTE_GERRIT_HOST} "tar czf gerrit_backup.tar.gz ${REMOTE_GERRIT_PATH}"

# Backup the remote PostgreSQL database
ssh -p ${REMOTE_GERRIT_PORT} ${REMOTE_GERRIT_USER}@${REMOTE_GERRIT_HOST} "pg_dump -Fc ${REMOTE_DB_NAME} > gerrit_db_backup.dump"

# Start Gerrit on the remote server
ssh -p ${REMOTE_GERRIT_PORT} ${REMOTE_GERRIT_USER}@${REMOTE_GERRIT_HOST} "gerrit.sh start"

# Transfer the Gerrit backup and database dump to the local server
rsync -avz -e "ssh -p ${REMOTE_GERRIT_PORT}" ${REMOTE_GERRIT_USER}@${REMOTE_GERRIT_HOST}:gerrit_backup.tar.gz /backup/
rsync -avz -e "ssh -p ${REMOTE_GERRIT_PORT}" ${REMOTE_GERRIT_USER}@${REMOTE_GERRIT_HOST}:gerrit_db_backup.dump /backup/

# Remove the backups from the remote server
ssh -p ${REMOTE_GERRIT_PORT} ${REMOTE_GERRIT_USER}@${REMOTE_GERRIT_HOST} "rm gerrit_backup.tar.gz gerrit_db_backup.dump"

# Restore the backup on the local server
cd ${LOCAL_GERRIT_BACKUP_PATH}
tar xzf gerrit_backup.tar.gz

# Restore the PostgreSQL database on the local server
pg_restore -C -Fc --no-owner --clean --if-exists -d ${LOCAL_DB_NAME} gerrit_db_backup.dump

# Note: You may need to adjust your Gerrit configuration and restart the local Gerrit instance after restoring the backup.
