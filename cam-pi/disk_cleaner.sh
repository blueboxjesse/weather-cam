#!/bin/bash
# http://stackoverflow.com/questions/5908919/shell-script-to-delete-files-when-disk-is-full 

FILESYSTEM=/dev/root
CAPACITY=95
CACHEDIR=/home/pi/weather-cam-tmp/

# Proceed if filesystem capacity is over than the value of CAPACITY (using df POSIX syntax)
# using [ instead of [[ for better error handling.
if [ $(df -P $FILESYSTEM | awk '{ gsub("%",""); capacity = $5 }; END { print capacity }') -gt $CAPACITY ]
then
    find "$CACHEDIR" -exec rm -f {} \;
    mkdir $CACHEDIR
fi 
