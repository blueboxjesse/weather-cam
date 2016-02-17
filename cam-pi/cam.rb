# cam.rb
# 
# Called via cron. Fetches a series of ENV variables from cam_wrapper.sh
#
# Accepts 1 argument: 
#   * Length of time in seconds to sleep before taking photo

# Configuration
image = "weather-#{ARGV[0]}.jpg"         # Filename cam.rb should write to.
twilight_offset = 15                     # Minutes after sunset to transition to twilight shutter.
image_store = "/var/tmp/"                # Path to the image store. On a Raspberry Pi, likely a RAM disk.
upload_log = "#{ENV['HOME']}/upload.log" # Upload log path

# Rapistill Configurations
raspistill_default = "-t 500 -awb horizon -w 2592 -h 1555 -q 100"
raspistill_twilight = "-ss 1000000 -ISO 200"
raspistill_night = "-ss 2000000 -ISO 200"
daytime_contrast = "0,8"

# Fetch sunrise / sunset data
require 'httparty'
sunset_data = JSON.parse(HTTParty.get("http://api.sunrise-sunset.org/json?lat=#{ENV['CAM_LAT']}&lng=#{ENV['CAM_LONG']}&date=#{Time.now.strftime('%Y-%m-%d')}&formatted=0").body)
sunset = Time.parse(sunset_data["results"]["sunset"])
sunrise = Time.parse(sunset_data["results"]["sunrise"])

if ARGV[0].to_i > 0
  puts "Sleeping for #{ARGV[0]}"
  `sleep #{ARGV[0]}`
end

# Main routine
# Daytime hours...
if Time.now < (sunset + twilight_offset * 60) && Time.now > (sunrise - twilight_offset * 60)
  puts "Daytime hours continue... Enfuse mode."
  start_time = Time.now
  
  puts "Snapping pictures..."
  `raspistill -ev -20 #{raspistill_default} -ex auto -o #{image_store}pic1-#{ARGV[0]}.jpg`
  puts "Pic 1. Elapsed execution time was #{Time.now - start_time}s."
  `raspistill -ev 0 #{raspistill_default} -ex auto -o #{image_store}pic2-#{ARGV[0]}.jpg`
  puts "Pic 2. Elapsed execution time was #{Time.now - start_time}s."
  `raspistill -ev +20 #{raspistill_default} -ex auto -o #{image_store}pic3-#{ARGV[0]}.jpg`
  puts "Pic 3. Elapsed execution time was #{Time.now - start_time}s."

  puts "Running enfuse..."
  `TMPDIR=#{image_store} enfuse -o #{image_store}#{image} #{image_store}pic1-#{ARGV[0]}.jpg #{image_store}pic2-#{ARGV[0]}.jpg #{image_store}pic3-#{ARGV[0]}.jpg > /dev/null`
  `rm #{image_store}pic1-#{ARGV[0]}.jpg #{image_store}pic2-#{ARGV[0]}.jpg #{image_store}pic3-#{ARGV[0]}.jpg`
  puts "Elapsed execution time was #{Time.now - start_time}s."
  
  puts "Running convert..."
  `convert #{image_store}#{image} -brightness-contrast #{daytime_contrast} #{image_store}#{image}`
  puts "Elapsed execution time was #{Time.now - start_time}s."

# Twilight Hours
elsif ( Time.now > sunset && Time.now < (sunset + twilight_offset * 60) ) || ( Time.now < sunrise && Time.now > (sunrise - twilight_offset * 60) )
  puts "Twilight... Enfuse mode."
  start_time = Time.now

  puts "Snapping pictures..."
  `raspistill -ev 0 #{raspistill_default} -o #{image_store}pic1-#{ARGV[0]}.jpg`
  `raspistill #{raspistill_twilight} #{raspistill_default} -o #{image_store}pic2-#{ARGV[0]}.jpg`

  puts "Running enfuse..."
  `TMPDIR=#{image_store} enfuse -o #{image_store}#{image} #{image_store}pic1-#{ARGV[0]}.jpg #{image_store}pic2-#{ARGV[0]}.jpg > /dev/null`
  `rm #{image_store}pic1-#{ARGV[0]}.jpg #{image_store}pic2-#{ARGV[0]}.jpg`
  puts "Elapsed execution time was #{Time.now - start_time}s."

# Evening / Dark
else
  puts "Evening hours continue... Single shot."
  `raspistill #{raspistill_default} #{raspistill_night} -o #{image_store}#{image}`
end

cam_path = File.expand_path(File.dirname(File.dirname(__FILE__)))
`bash #{cam_path}/cam-pi/upload.sh #{ARGV[0]} > #{upload_log}`
