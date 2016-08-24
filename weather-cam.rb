Bundler.require
require 'sinatra/asset_pipeline'

# Grab Memcache information from CF supplied VCAP_SERVICES
unless ENV['VCAP_SERVICES'].nil?
  vcap_services = JSON.parse(ENV['VCAP_SERVICES'])
  mc = vcap_services['memcachedcloud'].first['credentials']
  $cache = Dalli::Client.new(mc['servers'], { username: mc['username'], password: mc['password'] })
end

class WeatherCam < Sinatra::Base
  register Sinatra::AssetPipeline
  
  get '/' do
    haml :index
  end
  
  get '/solar' do
    if $cache
      @solar = $cache.get("solar-#{Date.today.yday}")
      @solar_time = $cache.get("solar_time-#{Date.today.yday}")
      if @solar == nil
        solar_xml = Nokogiri::XML(HTTParty.get(ENV['TIGO_URL']).body)
        @solar = (solar_xml.xpath("//Energy").first.child.to_s.to_f / 1000).round(2)
        @solar_time = Time.now
        $cache.set("solar-#{Date.today.yday}", @solar, 20*60)
        $cache.set("solar_time-#{Date.today.yday}", @solar_time, 20*60)
      end
    end
    haml :solar
  end
end