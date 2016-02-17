require 'sinatra'
require 'haml'
require 'json'

require 'httparty'
require 'nokogiri'
require 'dalli'

$cache = Dalli::Client.new(ENV['MEMCACHE_SERVER'], { username: ENV['MEMCACHE_USER'], password: ENV['MEMCACHE_PASS'] })

get '/' do
  haml :index
end

get '/solar' do
  if $cache
    @solar = $cache.get("solar-#{Date.today.yday}")
    @solar_time = $cache.get("solar_time-#{Date.today.yday}")
    if @solar == nil
      solar_xml = Nokogiri::XML(HTTParty.get(ENV['MEMCACHE_SERVER']).body)
      @solar = (solar_xml.xpath("//Energy").first.child.to_s.to_f / 1000).round(2)
      @solar_time = Time.now
      $cache.set("solar-#{Date.today.yday}", @solar, 20*60)
      $cache.set("solar_time-#{Date.today.yday}", @solar_time, 20*60)
    end
  end
  haml :solar
end