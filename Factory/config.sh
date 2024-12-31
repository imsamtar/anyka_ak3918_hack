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
ntpd -n -N -q -p 0.asia.pool.ntp.org &
ntpd -n -N -q -p 1.asia.pool.ntp.org &
export TZ=$time_zone

telnetd &
ak_adec_demo 38000 2 mp3 /mnt/Factory/media/Tutturuu_low.mp3
/mnt/Factory/apps/ptz/ptz_daemon & 
/mnt/Factory/apps/busybox httpd -p 8080 -h /mnt/Factory/apps/www &
sleep 5
/mnt/Factory/apps/rtsp/rtsp &


OUTPUT_DIR="/mnt/record"
RTSP_URL="rtsp://127.0.0.1:554/vs0"

mkdir -p $OUTPUT_DIR

while [ 1 ]; do
    ntpd -n -N -q -p 0.asia.pool.ntp.org &
    FILENAME="$(date +%s).h264"
    /mnt/Factory/apps/ffmpeg/ffmpeg -i "$RTSP_URL" -vcodec copy -acodec copy -f h264 "$OUTPUT_DIR/$FILENAME" &
    sleep 150
    pkill -9 -f "./ffmpeg -i $RTSP_URL"
done

while [ 1 ]; do
    sleep 30
done
