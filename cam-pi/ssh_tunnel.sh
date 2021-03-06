#!/bin/bash

source $HOME/.weather-cam

createTunnel() {
  /usr/bin/ssh -N -R $JUMPBOX_PORT:localhost:22 $JUMPBOX_USER@$JUMPBOX_IP
  if [[ $? -eq 0 ]]; then
    echo Tunnel to jumpbox created successfully
  else
    echo An error occurred creating a tunnel to jumpbox. RC was $?
  fi
}

/bin/pidof ssh

if [[ $? -ne 0 ]]; then
  echo Creating new tunnel connection
  createTunnel
fi
