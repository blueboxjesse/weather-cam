#!/bin/bash

source $HOME/.weather-cam

PROGRAM=`basename "$0"`

cd ~/
HOMEDIR=`pwd`

if [ "$#" -ne 3 ]; then
  echo "$PROGRAM Usage: $PROGRAM MONTH DAY YEAR"
  exit
fi

DAY=$2
MONTH=$1
YEAR=$3

mkdir -p ~/videos/$YEAR-$DAY
cd ~/videos/$YEAR-$DAY

swift download weather-cam-$YEAR-$DAY --skip-identical

mencoder -nosound -ovc copy -o $YEAR-$DAY.avi -mf w=2592:h=1555:fps=40:type=jpg mf://*.jpg
avconv -i $YEAR-$DAY.avi -c:v h264 -c:a copy -s 2592x1556 $YEAR-$DAY-h264.avi

/usr/local/bin/youtube-upload --tags=$WEATHER_CAM_VID_TAGS -d $WEATHER_CAM_VID_DESCRIPTION --title "WEATHER_CAM_VID_TITLE $YEAR Day $DAY" --privacy=public --playlist=$WEATHER_CAM_VID_PLAYLIST --client-secrets=$HOME/youtube_client_secret.json ~/videos/$YEAR-$DAY/$YEAR-$DAY-h264.avi

rm -rf ~/videos/$YEAR-$DAY
