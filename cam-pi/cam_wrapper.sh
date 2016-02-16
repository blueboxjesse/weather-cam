#!/bin/bash

source ~/.openstack-creds

ruby $HOME/weather-cam/cam-pi/cam.rb $1
