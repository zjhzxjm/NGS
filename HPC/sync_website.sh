#!bin/bash
echo "script start at" `date +"%Y-%m-%d %H:%M:%S"`
export HOST=
export USER=
export PASS=
export LCD=/data_center_05/html/realbio
export RCD=/test632/web/test
/usr/bin/lftp << EOF
open ftp://$USER:$PASS@$HOST
mirror $RCD $LCD
EOF
echo "script end at" `date +"%Y-%m-%d %H:%M:%S"`
