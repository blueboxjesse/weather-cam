#!/bin/bash

# video-cron.sh
#
# Used to execute the video-creator via cron

YEAR=`date -d "yesterday 00:00" '+%Y'`
MONTH=`date -d "yesterday 00:00" '+%m'`
DAY=`date -d "yesterday 00:00" '+%j'`

bash $HOME/weather-cam/cam-control/video-creator.sh $MONTH $DAY $YEAR
