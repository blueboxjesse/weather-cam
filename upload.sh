#!/bin/sh

source ~/.openstack-creds

BUCKET=`date +%Y-%j`
DATE_STAMP=`date +%Y-%m-%d-%H-%M-%S`

cd /var/tmp/

echo "Uploading weather-$1.jpg"
mv weather-$1.jpg $DATE_STAMP.jpg

timeout 20s /usr/local/bin/swift --os-auth-url $OS_AUTH_URL --auth-version 3 --os-region-name $OS_REGION_NAME --os-project-name $OS_PROJECT_NAME --os-project-domain-name $OS_PROJECT_DOMAIN_NAME --os-username $OS_USERNAME --os-user-domain-name $OS_USER_DOMAIN_NAME --os-password $OS_PASSWORD upload weather-cam /var/tmp/$DATE_STAMP.jpg --object-name weather.jpg

echo "Uploading Timestamped Pic $DATE_STAMP.jpg to $BUCKET"

timeout 20s /usr/local/bin/swift --os-auth-url $OS_AUTH_URL --auth-version 3 --os-region-name $OS_REGION_NAME --os-project-name $OS_PROJECT_NAME --os-project-domain-name $OS_PROJECT_DOMAIN_NAME --os-username $OS_USERNAME --os-user-domain-name $OS_USER_DOMAIN_NAME --os-password $OS_PASSWORD upload weather-cam-$BUCKET /var/tmp/$DATE_STAMP.jpg --object-name $DATE_STAMP.jpg

rm /var/tmp/$DATE_STAMP.jpg
