#!/bin/sh

export LD_LIBRARY_PATH=/mnt/Factory/apps/lib

source /mnt/env.cfg
factorycfg=/usr/local/factory_cfg.ini
cfgfile=/etc/jffs2/anyka_cfg.ini

readline() {
  linetoread=$1
  file=$2
  sed $linetoread'q;d' $file
}

input_wifi_creds() {
  echo 'adding new wifi credentials'
  i=1
  let linecountlimit=$(wc -l < $cfgfile)
  echo "$linecountlimit lines"
  newcredfile=/mnt/Factory/anyka_cfg.ini
  echo -n "" > $newcredfile
  while [ $i -le $linecountlimit ]; do
    line=$(readline $i $cfgfile)
    if [[ "${line:0:4}" == "ssid" ]]; then
      echo "insert $wifi_ssid on line $i"
      echo "ssid = $wifi_ssid">> $newcredfile
    else
      if [[ "${line:0:8}" == "password" ]]; then
        echo "insert $wifi_password on line $i"
        echo "password = $wifi_password">> $newcredfile
      else
        echo "$line">> $newcredfile
      fi
    fi
    let i++
  done
  mv $cfgfile $newcredfile.old
  cp $newcredfile $cfgfile
}

input_wifi_creds

/usr/sbin/net_manage.sh &
export TZ=$time_zone

telnetd &
ak_adec_demo 38000 2 mp3 /mnt/Factory/media/Tutturuu_low.mp3
/mnt/Factory/apps/ptz/ptz_daemon & 
/mnt/Factory/apps/busybox httpd -p 8080 -h /mnt/Factory/apps/www &
sleep 5
/mnt/Factory/apps/rtsp/rtsp &
ntpd -n -N -q -p $(cat /tmp/gw0)

mkdir -p /mnt/record
while [ "$(date +%s)" -lt 1735652000 ]; then
    ntpd -n -N -q -p 0.asia.pool.ntp.org
    sleep 5
fi

while [ 1 ]; do
    RTSP_URL="rtsp://127.0.0.1:554/vs0"
    FILENAME="/mnt/record/$(date +"%H:%M:%S_%d:%m:%Y").h264"
    /mnt/Factory/apps/ffmpeg/ffmpeg -threads 1 -i $RTSP_URL -vcodec copy -acodec copy -f h264 "/mnt/record/RAND_$RND.h264" &
    sleep 10
    while pgrep -x /mnt/Factory/apps/ffmpeg/ffmpeg > /dev/null; do
        sleep 30
    done
    # pkill -n -f "/mnt/Factory/apps/ffmpeg/ffmpeg -i $RTSP_URL"
done

while [ 1 ]; do
    sleep 30
done
