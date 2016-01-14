# weather-cam

## Raspberry Pi Crontabs
```
# m h  dom mon dow   command
*/1 * * * * /usr/local/bin/lockrun --lockfile=/home/pi/queen-anne-cam/cam1.lock -- ruby /home/pi/queen-anne-cam/cam.rb 0
*/1 * * * * /usr/local/bin/lockrun --lockfile=/home/pi/queen-anne-cam/cam2.lock -- ruby /home/pi/queen-anne-cam/cam.rb 30
*/1 * * * * /home/pi/queen-anne-cam/ssh_tunnel.sh > tunnel.log 2>&1
*/1 * * * * /home/pi/queen-anne-cam/temperature.sh
```
