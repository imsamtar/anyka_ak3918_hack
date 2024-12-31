#!/bin/sh

export LD_LIBRARY_PATH=/mnt/Factory/apps/lib

source /mnt/Factory/env.cfg
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
  let linecountlimit=$(wc -l < $factorycfg)
  echo "$linecountlimit lines"
  newcredfile=/mnt/Factory/anyka_cfg.ini
  echo -n "" > $newcredfile
  while [ $i -le $linecountlimit ]; do
    line=$(readline $i $factorycfg)
    if [[ "${line:0:4}" == "ssid" ]]; then
      echo "insert $wifi_ssid on line $i"
      printf "$(cat $newcredfile)\\nssid = $wifi_ssid" > $newcredfile
    else
      if [[ "${line:0:8}" == "password" ]]; then
        echo "insert $wifi_password on line $i"
        printf "$(cat $newcredfile)\\npassword = $wifi_password">> $newcredfile
      else
        printf "$(cat $newcredfile)\\n$line">> $newcredfile
      fi
    fi
    let i++
  done
  mv $cfgfile $newcredfile.old
  cp $newcredfile $cfgfile
}

input_wifi_creds

/usr/sbin/net_manage.sh &
ntpd -n -N -p $time_source &
export TZ=$time_zone

telnetd &
ak_adec_demo 16000 2 mp3 /mnt/Factory/media/Tutturuu_low.mp3
/mnt/Factory/apps/ptz/ptz_daemon & 
/mnt/Factory/apps/busybox httpd -p 8080 -h /mnt/Factory/apps/www &
sleep 5
/mnt/Factory/apps/rtsp/rtsp &

while [ 1 ]; do
    sleep 30
done
