#!/bin/bash

source ~/.openstack-creds

BUCKET=`date +%Y-%j`
DATE_STAMP=`date +%Y-%m-%d-%H-%M-%S`

MEMORY_STORAGE=/var/tmp
RESIDENT_STORAGE=/tmp/weather-cam

if [[ $# -eq 0 ]] ; then

  echo "Upload Mode: Batch"
 
  for FILE_PATH in $RESIDENT_STORAGE/$BUCKET/* ; do
    FILE=`basename "$FILE_PATH"`
    echo "Uploading $FILE_PATH to $FILE in $BUCKET"

    until timeout 20s /usr/local/bin/swift upload weather-cam-$BUCKET $FILE_PATH --object-name $FILE --skip-identical; do
      echo "Upload of $FILE failed... Exit code: $?. Trying again..."
    done

    rm $FILE_PATH

  done

else

  echo "Upload Mode: weather.jpg"
  FILE=$RESIDENT_STORAGE/$BUCKET/$DATE_STAMP.jpg

  mkdir -p $RESIDENT_STORAGE/$BUCKET
  mv $MEMORY_STORAGE/weather-$1.jpg $FILE

  echo "Uploading weather-$1.jpg"
  timeout 15s /usr/local/bin/swift upload weather-cam $FILE --object-name weather.jpg
  echo "Upload success: $?"
  
fi
