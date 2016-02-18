# weather-cam

This is the source code that powers http://queen-anne.seattle.watch. A full blog post on that 
installation is forthcoming.

This project is licensed under the MIT license. Please feel free to contribute!

This README covers pre-reqs, installation instructions and general pointers. please 

## Pre-requisites
This set of code was developed as a way for [@blueboxjesse](https://twitter.com/blueboxjesse) to test out IBM's Public Cloud service catalogue. It uses a combination of 

**You will need:**
* Raspberry Pi w/ Camera Module running the cam-pi code
* [IBM Bluemix](https://www.bluemix.net) Virtual Machine running the cam-control code
* [IBM Bluemix](https://www.bluemix.net) Cloud Foundry implementation running the embedded Sinatra app 
* [IBM Bluemix](https://www.bluemix.net) Object Storage account

## Installation

Follow these steps for installation:

* Check out this repository in the home directory for the Cam-Pi and the Cam-Control servers.
* Download and install [Lockrun](https://github.com/pushcx/lockrun) on both Cam-Pi and Cam Control.
* For the sake of the crontabs, set the timezone on Cam-Pi and Cam-Control to your local time zone (sudo dpkg-reconfigure tzdata)

**In Bluemix:**
You need to set the following environmental variables in your Bluemix Cloud Foundry app:

```
WEATHER_JPG_URL: https://dal.objectstorage.open.softlayer.com/v1/AUTH_09efdd634bf5483ebdf24ff6a166db27/weather-cam/weather.jpg
WEATHER_UNDERGROUND_ID: KWASEATT457

# If querying a Tigo Solar array
MEMCACHE_PASS: 
MEMCACHE_SERVER: 
MEMCACHE_USER: 
TIGO_URL: 
```

Once those are set, a simple cf push will publish the app.

**On Cam-Control:**

Install [YouTube Upload](https://github.com/tokland/youtube-upload) on Cam-Control, then follow the authentication steps laid out [here](https://github.com/tokland/youtube-upload#authentication) and install the output into: ~/youtube_client_secret.json

```
sudo apt-get install unzip
mkdir -p ~/source
cd ~/source
wget https://github.com/tokland/youtube-upload/archive/master.zip
unzip master.zip
cd youtube-upload-master
sudo python setup.py install
sudo pip install --upgrade google-api-python-client progressbar2

sudo apt-get install git python-pip python-dev libffi-dev python-pyasn1 libssl-dev
sudo pip install python-swiftclient python-keystoneclient wrapt cryptography
sudo pip install --upgrade ndg-httpsclient
```

## Configuration

This code sources a configuration file from ~/.weather-cam. This configuration value requires the following 
environmental variables:

### ~/.weather-cam
The cam-pi and cam-control programs expect a configuration file in the home directory with the following variable defined:

```
export OS_USER_ID=""
export OS_PASSWORD=""
export OS_PROJECT_ID=""
export OS_AUTH_URL=https://identity.open.softlayer.com/v3
export OS_REGION_NAME=dallas
export OS_IDENTITY_API_VERSION=3
export OS_AUTH_VERSION=3

export JUMPBOX_USER=""
export JUMPBOX_IP=""
export JUMPBOX_PORT=2222

export TWILIO_USER=
export TWILIO_PASS=
export TWILIO_NUMB=""
export TWILIO_TO=
export TWILIO_FROM=

export CAM_LAT=""
export CAM_LONG=""
export CAM_NAME="QA"
export CAM_PORT=2222

export WEATHER_CAM_VID_TITLE="Seattle Weather Time-lapse"
export WEATHER_CAM_VID_TAGS='Weather Cam,Time-lapse,Timelapse,Seattle,Skyline'
export WEATHER_CAM_VID_PLAYLIST="Seattle Skyline Time-lapse Recordings"
export WEATHER_CAM_VID_DESCRIPTION='Historical time-lapse of the Seattle Skyline, straight from Queen Anne Cam. Visit http://seattle.watch for live imagery or check out this playlist: https://www.youtube.com/playlist?list=PLr4_vl1czq4tm9syl_pK5VmQfsiMtZr_0. Powered by IBM Bluemix and @blueboxjesse'
```

### Crontabs
Set the following crontabs:

#### Raspberry Pi Crontabs
```
HOME=/home/pi
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# m h  dom mon dow   command
*/1 * * * * /usr/local/bin/lockrun --lockfile=/home/pi/cam1.lock -- bash /home/pi/weather-cam/cam-pi/cam_wrapper.sh 0
*/1 * * * * /usr/local/bin/lockrun --lockfile=/home/pi/cam2.lock -- bash /home/pi/weather-cam/cam-pi/cam_wrapper.sh 30
*/1 * * * * /home/pi/weather-cam/cam-pi/ssh_tunnel.sh > tunnel.log 2>&1
*/1 * * * * /home/pi/weather-cam/cam-pi/temperature.sh
*/10 * * * * /usr/local/bin/lockrun --lockfile=/home/pi/upload.lock -- bash /home/pi/weather-cam/cam-pi/upload.sh
59 23 * * * bash /home/pi/weather-cam/cam-pi/upload.sh
@reboot /home/pi/weather-cam/cam-pi/network_reconnect.sh
```

#### cam-control Crontabs
```
HOME="/home/user"
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# m h  dom mon dow   command
0 5 * * * bash /home/user/weather-cam/cam-control/video-cron.sh > /home/user/cron.log
*/5 * * * * bash /home/user/weather-cam/cam-control/video-update-check.sh > /home/user/check.log
```