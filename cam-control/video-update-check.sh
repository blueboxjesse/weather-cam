#!/bin/bash

OBJECT_DATE=`swift stat weather-cam weather.jpg | grep "X-Timestamp: " | cut -d ":" -f2 | bc`
OBJECT_DATE=${OBJECT_DATE/.*}

# Allow 5 minute delay
CURRENT_DATE=`date "+%s"`
CHECK_DATE=`expr $CURRENT_DATE - 300`
DIFFERENCE_DATE=`expr $CURRENT_DATE - $OBJECT_DATE`

nc -z 127.0.0.1 2222
TUNNEL_STATUS=`echo $?`
if [ "$TUNNEL_STATUS" -eq "0" ]; then
  TUNNEL_STATUS='Online'
else
  TUNNEL_STATUS='Offline'
fi

if [ "$OBJECT_DATE" -lt "$CHECK_DATE" ]; then

# Notify
curl -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_USER/Messages.json" \
--data-urlencode 'To=+12067788777'  \
--data-urlencode 'From=+12065390328'  \
--data-urlencode "Body=QA Cam pic delayed $DIFFERENCE_DATE. Last upload: $OBJECT_DATE, current date: $CURRENT_DATE. Tunnel Status: $TUNNEL_STATUS" \
-u $TWILIO_USER:$TWILIO_PASS

else

  echo "Update current... Delay: $DIFFERENCE_DATE, last upload: $OBJECT_DATE, current date: $CURRENT_DATE. Tunnel Status: $TUNNEL_STATUS"

fi
