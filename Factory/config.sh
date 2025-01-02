#!/bin/sh

export LD_LIBRARY_PATH=/mnt/Factory/apps/lib

source /mnt/env.cfg
factorycfg=/usr/local/factory_cfg.ini
cfgfile=/etc/jffs2/anyka_cfg.ini

lookaround() {
  echo "t2p 184 82" >/tmp/ptz.daemon
  sleep 10
  echo "t2p 184 73" >/tmp/ptz.daemon
  sleep 10
  echo "t2p 184 55" >/tmp/ptz.daemon
  sleep 5
  echo "t2p 205 45" >/tmp/ptz.daemon
  sleep 5
  echo "t2p 225 36" >/tmp/ptz.daemon
  sleep 5
  echo "t2p 250 45" >/tmp/ptz.daemon
  sleep 5
  echo "t2p 225 36" >/tmp/ptz.daemon
  sleep 5
  echo "t2p 225 86" >/tmp/ptz.daemon
  sleep 5
  echo "t2p 225 36" >/tmp/ptz.daemon
  sleep 5
  echo "t2p 205 45" >/tmp/ptz.daemon
  sleep 5
  echo "t2p 184 55" >/tmp/ptz.daemon
  sleep 5
  echo "t2p 184 73" >/tmp/ptz.daemon
}

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
ntpd -n -N -q -p $(cat /tmp/gw0) &
sleep 20

if [ ! -d "/mnt/record" ]
  mkdir -p /mnt/record
  touch /mnt/record/rec
fi

while [ $(date +%s) -lt 1735652000 ]; do
    ntpd -n -N -q -p 0.asia.pool.ntp.org &
    sleep 5
done

ak_adec_demo 16000 2 aac /data/audio_file/chs/1002.aac

while [ 1 ]; do
  if [ -d "/mnt/record" ] && [ -f "/mnt/record/rec" ]; then
    echo 3 > /proc/sys/vm/drop_caches
    sleep 1
    /mnt/Factory/apps/ffmpeg/ffmpeg -threads 1 -i rtsp://127.0.0.1:554/vs1 -r 3 -vcodec copy -an -f h264 /mnt/record/$(date +"%Y_%m_%d-%H_%M_%S").h264 &
    sleep 5
    while pgrep -x /mnt/Factory/apps/ffmpeg/ffmpeg > /dev/null; do
        if [ -d "/mnt/record" ] && [ -f "/mnt/record/rec" ]; then
          if [ $RANDOM -lt 273 ]; then
            lookaround
          fi
          sleep 10
        else
          pkill -9 /mnt/Factory/apps/ffmpeg/ffmpeg
        fi
    done
  fi
  sleep 10
done
