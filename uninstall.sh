#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SERVICE_NAME=$(basename $SCRIPT_DIR)

rm /service/$SERVICE_NAME
kill $(pgrep -f 'supervise dbus-evcc')
chmod a-x $SCRIPT_DIR/service/run
./restart.sh
# remove entry from rc.local
filename=/data/rc.local
sed -i '/$SERVICE_NAME/d' $filename
