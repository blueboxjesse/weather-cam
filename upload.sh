#!/bin/sh

. ~/.openstack-creds

BUCKET=`date +%Y-%j`
DATE_STAMP=`date +%Y-%m-%d-%H-%M-%S`

cd /var/tmp/

echo "Uploading weather-$1.jpg"
mv weather-$1.jpg $DATE_STAMP.jpg

timeout 20s /usr/local/bin/swift upload weather-cam /var/tmp/$DATE_STAMP.jpg --object-name weather.jpg

echo "Uploading Timestamped Pic $DATE_STAMP.jpg to $BUCKET"

timeout 20s /usr/local/bin/swift upload weather-cam-$BUCKET /var/tmp/$DATE_STAMP.jpg --object-name $DATE_STAMP.jpg

rm /var/tmp/$DATE_STAMP.jpg
