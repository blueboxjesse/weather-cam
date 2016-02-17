#!/bin/bash

# video-creater.sh
#
# Accepts 3 inputs:
#   * Month - Numeric month (i.e. 01)
#   * Day of Year - Numeric day of the year (i.e. 46)
#   * Year - Numeric full year (i.e. 2016)

source $HOME/.weather-cam

if [ "$#" -ne 3 ]; then
  PROGRAM=`basename "$0"`
  echo "$PROGRAM Usage: $PROGRAM MONTH DAY_OF_YEAR YEAR"
  exit
fi

DAY=$2
MONTH=$1
YEAR=$3

# Grab all still frames for the day
mkdir -p ~/videos/$YEAR-$DAY
cd ~/videos/$YEAR-$DAY
swift download weather-cam-$YEAR-$DAY --skip-identical

# Produce and upload movie
mencoder -nosound -ovc copy -o $YEAR-$DAY.avi -mf w=2592:h=1555:fps=40:type=jpg mf://*.jpg
avconv -i $YEAR-$DAY.avi -c:v h264 -c:a copy -s 2592x1556 $YEAR-$DAY-h264.avi

youtube-upload --tags="$WEATHER_CAM_VID_TAGS" -d "$WEATHER_CAM_VID_DESCRIPTION" --title "$WEATHER_CAM_VID_TITLE $YEAR Day $DAY" --privacy=public --playlist="$WEATHER_CAM_VID_PLAYLIST" --client-secrets=$HOME/youtube_client_secret.json $HOME/videos/$YEAR-$DAY/$YEAR-$DAY-h264.avi

if [ $? -eq 0 ]; then
  rm -rf $HOME/videos/$YEAR-$DAY
fi
