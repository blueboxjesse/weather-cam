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
```

## Required Software
### cam-control
```
sudo apt-get install gcc gcc+ yasm make
wget https://www.mplayerhq.hu/MPlayer/releases/MPlayer-1.2.tar.xz
tar -xJf MPlayer-1.2.tar.xz
cd MPlayer-1.2/
./configure
make
make install
```

## Crontabs

### Raspberry Pi
```
# m h  dom mon dow   command
*/1 * * * * /usr/local/bin/lockrun --lockfile=/home/pi/queen-anne-cam/cam1.lock -- ruby /home/pi/queen-anne-cam/cam.rb 0
*/1 * * * * /usr/local/bin/lockrun --lockfile=/home/pi/queen-anne-cam/cam2.lock -- ruby /home/pi/queen-anne-cam/cam.rb 30
*/1 * * * * /home/pi/queen-anne-cam/ssh_tunnel.sh > tunnel.log 2>&1
*/1 * * * * /home/pi/queen-anne-cam/temperature.sh
```

### cam-control
```
# m h  dom mon dow   command
0 1 * * * /home/ibmcloud/queen-anne-cam/video-cron.sh
*/5 * * * * /home/ibmcloud/queen-anne-cam/video-update-check.sh
```
