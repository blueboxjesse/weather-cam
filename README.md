# weather-cam

## ~/.openstack-creds 
```
export OS_USER_ID=""
export OS_PASSWORD=""
export OS_PROJECT_ID=""
export OS_AUTH_URL=https://identity.open.softlayer.com/v3
export OS_REGION_NAME=dallas
export OS_IDENTITY_API_VERSION=3
export OS_AUTH_VERSION=3

export TWILIO_USER=
export TWILIO_PASS=
export TWILIO_NUMB=""
```

## Required Software and Setup
### cam-control

Use Ubuntu 14.04. Ubuntu 15.04 does not include mencoder in its package respository and building from scratch is a great way to ruin your day.

Set the timezone:
```
sudo dpkg-reconfigure tzdata
```

Install the following software:
```
sudo apt-get install git python-pip python-dev libffi-dev python-pyasn1 libssl-dev
sudo pip install python-swiftclient python-keystoneclient wrapt cryptography
sudo pip install --upgrade ndg-httpsclient
cd ~/
git clone git@github.com:blueboxjesse/weather-cam.git
```

Install youtube upload (https://github.com/tokland/youtube-upload):
```
sudo apt-get install unzip
mkdir -p ~/source
cd ~/source
wget https://github.com/tokland/youtube-upload/archive/master.zip
unzip master.zip
cd youtube-upload-master
sudo python setup.py install
sudo pip install --upgrade google-api-python-client progressbar2
```

Then follow the authentication steps laid out here:
https://github.com/tokland/youtube-upload#authentication

Install the output into: ~/youtube_client_secret.json

Create the pi tunnel user and add the camera's SSH key:
```
sudo adduser pi
```


## Crontabs

### Raspberry Pi
```
# m h  dom mon dow   command
*/1 * * * * /usr/local/bin/lockrun --lockfile=/home/pi/queen-anne-cam/cam1.lock -- ruby /home/pi/queen-anne-cam/cam-pi/cam.rb 0
*/1 * * * * /usr/local/bin/lockrun --lockfile=/home/pi/queen-anne-cam/cam2.lock -- ruby /home/pi/queen-anne-cam/cam-pi/cam.rb 30
*/1 * * * * /home/pi/queen-anne-cam/cam-pi/ssh_tunnel.sh > tunnel.log 2>&1
*/1 * * * * /home/pi/queen-anne-cam/cam-pi/temperature.sh
```

### cam-control
```
# m h  dom mon dow   command
0 1 * * * bash ~/weather-cam/cam-control/video-cron.sh
*/5 * * * * bash ~/weather-cam/cam-control/video-update-check.sh
```
