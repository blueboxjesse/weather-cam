#!/bin/bash

while true ; do
  if ifconfig wlan0 | grep -q "inet addr:" ; then
    echo -n "."
    sleep 5
  else
    echo "\nNetwork connection down! Attempting reconnection.\n"
    ifup --force wlan0
    sleep 10
 fi
done
