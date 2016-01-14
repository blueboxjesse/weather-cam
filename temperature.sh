#!/bin/bash

rec_temp () {
  TEMP=`/opt/vc/bin/vcgencmd measure_temp`
  DATE=`date`
  echo "$DATE $TEMP" >> temperature.log
}

for count in 1 2 3 4 5 6
do
  rec_temp
  sleep 10
done
