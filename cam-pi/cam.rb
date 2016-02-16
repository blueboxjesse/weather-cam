require 'httparty'

today = Time.now.strftime("%Y-%m-%d")

response = JSON.parse(HTTParty.get("http://api.sunrise-sunset.org/json?lat=#{ENV['CAM_LAT']}&lng=#{ENV['CAM_LONG']}&date=#{today}&formatted=0").body)

sunset = Time.parse(response["results"]["sunset"])
sunrise = Time.parse(response["results"]["sunrise"])

image = "weather-#{ARGV[0]}.jpg"

twilight_offset=15

if ARGV[0].to_i > 0
  puts "Sleeping for #{ARGV[0]}"
  `sleep #{ARGV[0]}`
end

if Time.now < (sunset + twilight_offset * 60) && Time.now > (sunrise - twilight_offset * 60)
  
  puts "Daytime hours continue... Enfuse mode."
  
  start_time = Time.now
  
  puts "Snapping pictures..."
  `raspistill -t 500 -awb horizon -w 2592 -h 1555 -ev -20 -ex auto -q 100 -o /var/tmp/pic1-#{ARGV[0]}.jpg`
  puts "Pic 1. Elapsed execution time was #{Time.now - start_time}s."
  `raspistill -t 500 -awb horizon -w 2592 -h 1555 -ev 0 -ex auto -q 100 -o /var/tmp/pic2-#{ARGV[0]}.jpg`
  puts "Pic 2. Elapsed execution time was #{Time.now - start_time}s."
  `raspistill -t 500 -awb horizon -w 2592 -h 1555 -ev +20 -ex auto -q 100 -o /var/tmp/pic3-#{ARGV[0]}.jpg`
  puts "Pic 3. Elapsed execution time was #{Time.now - start_time}s."

  puts "Running enfuse..."
  `TMPDIR=/var/tmp/ enfuse -o /var/tmp/#{image} /var/tmp/pic1-#{ARGV[0]}.jpg /var/tmp/pic2-#{ARGV[0]}.jpg /var/tmp/pic3-#{ARGV[0]}.jpg > /dev/null`
  `rm /var/tmp/pic1-#{ARGV[0]}.jpg /var/tmp/pic2-#{ARGV[0]}.jpg /var/tmp/pic3-#{ARGV[0]}.jpg`
  puts "Elapsed execution time was #{Time.now - start_time}s."
  
  puts "Running convert..."
  `convert /var/tmp/#{image} -brightness-contrast 0,8 /var/tmp/#{image}`
  puts "Elapsed execution time was #{Time.now - start_time}s."


elsif ( Time.now > sunset && Time.now < (sunset + twilight_offset * 60) ) || ( Time.now < sunrise && Time.now > (sunrise - twilight_offset * 60) )

  puts "Twilight... Enfuse mode."

  start_time = Time.now

  puts "Snapping pictures..."
  `raspistill -t 500 -awb horizon -w 2592 -h 1555 -ev 0 -ex auto -q 100 -o /var/tmp/pic1-#{ARGV[0]}.jpg`
  `raspistill -t 500 -awb horizon -w 2592 -h 1555 -ss 2000000 -ISO 200 -o /var/tmp/pic2-#{ARGV[0]}.jpg`

  puts "Running enfuse..."
  `TMPDIR=/var/tmp/ enfuse -o /var/tmp/#{image} /var/tmp/pic1-#{ARGV[0]}.jpg /var/tmp/pic2-#{ARGV[0]}.jpg > /dev/null`
  `rm /var/tmp/pic1-#{ARGV[0]}.jpg /var/tmp/pic2-#{ARGV[0]}.jpg`
  puts "Elapsed execution time was #{Time.now - start_time}s."

else
 
  puts "Evening hours continue... Single shot."

  start_time = Time.now
  puts "Snapping pictures..."
  `raspistill -t 500 -awb horizon -w 2592 -h 1555 -ss 2000000 -ISO 200 -o /var/tmp/#{image}`

end

cam_path = File.expand_path(File.dirname(File.dirname(__FILE__)))
`bash #{cam_path}/cam-pi/upload.sh #{ARGV[0]} > /tmp/upload.log`
