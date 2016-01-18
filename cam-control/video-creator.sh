#!/bin/bash

source ~/.openstack-creds

PROGRAM=`basename "$0"`

if [ "$#" -ne 3 ]; then
  echo "$PROGRAM Usage: $PROGRAM MONTH DAY YEAR"
  exit
fi

DAY=$2
MONTH=$1
YEAR=$3

mkdir -p ~/videos/$YEAR-$DAY
cd ~/videos/$YEAR-$DAY

swift download weather-cam-$YEAR-$DAY

ls *.jpg > stills.txt

mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4:aspect=16/9:vbitrate=8000000 -vf scale=2592:1555 -o  $YEAR-$DAY.avi -mf type=jpeg:fps=24 mf://@stills.txt
# mencoder -nosound -ovc copy -o $YEAR-$DAY.avi -mf w=2592:h=1555:fps=18:type=jpg mf://@stills.txt

/usr/local/bin/youtube-upload --title "Seattle Weather Time-lapse $YEAR Day $DAY" --privacy=public --playlist="Seattle Skyline Time-lapse Recordings" --client-secrets=/home/ibmcloud/youtube-upload-settings/client_secret.json /home/ibmcloud/videos/$YEAR-$DAY/$YEAR-$DAY.avi

rm -rf ~/videos/$YEAR-$DAY
