#!/bin/bash

# video-update-check.sh
#
# Check the status of the current weather.jpg image to ensure freshness.
# Notify via Twilio if stale.

source $HOME/.weather-cam

OBJECT_DATE=`swift stat weather-cam weather.jpg | grep "X-Timestamp: " | cut -d ":" -f2 | bc`
OBJECT_DATE=${OBJECT_DATE/.*}

# Allow 5 minute delay
CURRENT_DATE=`date "+%s"`
CHECK_DATE=`expr $CURRENT_DATE - 300`
DIFFERENCE_DATE=`expr $CURRENT_DATE - $OBJECT_DATE`

# Check tunnel status to Cam
nc -z 127.0.0.1 $CAM_PORT
TUNNEL_STATUS=`echo $?`
if [ "$TUNNEL_STATUS" -eq "0" ]; then
  TUNNEL_STATUS='Online'
else
  TUNNEL_STATUS='Offline'
fi

if [ "$OBJECT_DATE" -lt "$CHECK_DATE" ]; then
  curl -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_USER/Messages.json" \
  --data-urlencode "To=$TWILIO_TO"  \
  --data-urlencode "From=$TWILIO_FROM"  \
  --data-urlencode "Body=$CAM_NAME delayed $DIFFERENCE_DATE s. Tunnel Status: $TUNNEL_STATUS" \
  -u $TWILIO_USER:$TWILIO_PASS
else
  echo "Update current... Delay: $DIFFERENCE_DATE, last upload: $OBJECT_DATE, current date: $CURRENT_DATE. Tunnel Status: $TUNNEL_STATUS"
fi
