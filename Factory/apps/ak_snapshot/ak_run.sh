#!/bin/sh

source /usr/sbin/camera.sh

export LD_LIBRARY_PATH=/oldcam/lib:/oldcam/usr/lib
./ak_snapshot
