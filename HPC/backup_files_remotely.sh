#!/bin/bash
# Nick Masluk
# last updated 2011-03-29

# To backup multiple source dirs into the backup dir, separate dirs with a space and do not end dir paths with a slash
# To copy the contents of the source dir into the backup dir, end with a slash


SSH_KEY=$HOME"/.ssh/id_rsa"
SOURCE_DIR=$1
BACKUP_DIR="xujm@$2:$3"
EXCLUDE="lost+found .identity"
LOG_FILE=$HOME"/logs/"$2"_backup_files_remotely_log.txt"
KEEP_LOG="2" # set to 0 to disable, 1 to keep a running log, 2 to delete the log and record only current session
LOCK_FILE=$HOME"/."$2"_backup_files_remotely_running"

# Check if a backup is already running.  If not, create file $LOCK_FILE to
# indicate to other instances of this script that a backup is running.
if [ ! -e $LOCK_FILE ]; then
  touch $LOCK_FILE
else
  echo "Backup is already running"
  # exit with error code 2 if a backup is already running
  exit 2
fi

if [ $KEEP_LOG -eq 1 ] || [ $KEEP_LOG -eq 2 ]; then
  # run backup logged
  if [ $KEEP_LOG -eq 2 ] && [ -e $LOG_FILE ]; then
    # if log mode is set to "2", delete old log file before starting (if it exists)
    rm -f $LOG_FILE
    touch $LOG_FILE
  fi
  # set log command to split stdout into a log file and stdout
  LOG_CMD="tee -a $LOG_FILE"
else
  # set log command to only print to stdout
  LOG_CMD="cat"
fi

date +%F\ %T\ %A | $LOG_CMD
echo "" | $LOG_CMD

# generate a list of items to ignore
#EXCLUDED=""
#for i in $EXCLUDE; do
#    EXCLUDED="$EXCLUDED --exclude=$i";
#done
#rsync -e "ssh -i $SSH_KEY" $EXCLUDED --delete-after -av $@ $SOURCE_DIR $BACKUP_DIR 2>&1 | $LOG_CMD
rsync -e "ssh -i $SSH_KEY" $EXCLUDED --delete-after -av $SOURCE_DIR $BACKUP_DIR 2>&1 | $LOG_CMD

# store error code from rsync's exit
ERROR=${PIPESTATUS[0]}
date +%F\ %T\ %A | $LOG_CMD
echo "" | $LOG_CMD
    echo "--------------------------------------------------------------------------------" | $LOG_CMD
# remove $LOCK_FILE to indicate that backup is no longer running
rm -f $LOCK_FILE
# exit with the error code left by rsync
exit $ERROR
