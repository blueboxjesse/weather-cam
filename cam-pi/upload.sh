#!/bin/bash

# upload.sh
#
# Uploads files to SoftLayer object storage.
#
# If executed with no arguments, presumes uploading in bulk all the locally stored images.
#
# If executed with 1 or more arguments, presumes it was executed from cam.rb and it is to
# upload the current weather.jpg.

source ~/.weather-cam

# Configuration
MEMORY_STORAGE=/var/tmp
RESIDENT_STORAGE=$HOME/weather-cam-tmp

# Main routine
: ${BUCKET=`date +%Y-%j`}
DATE_STAMP=`date +%Y-%m-%d-%H-%M-%S`
mkdir -p $RESIDENT_STORAGE/$BUCKET

if [[ $# -eq 0 ]] ; then

  echo "Upload Mode: Batch Python Process"
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  /usr/bin/env python $DIR/upload.py
  
else

  echo "Upload Mode: weather.jpg"
  FILE=$RESIDENT_STORAGE/$BUCKET/$DATE_STAMP.jpg
  mv $MEMORY_STORAGE/weather-$1.jpg $FILE
  timeout 25s swift upload weather-cam $FILE --object-name weather.jpg &
  
fi
