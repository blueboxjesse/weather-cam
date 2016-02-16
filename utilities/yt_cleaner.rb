require 'rubygems'
require 'active_support/core_ext/hash'
require 'yt'

Yt.configure do |config|
  config.client_id = ''
  config.client_secret = ''
end

Yt::Account.new(scopes: 'https://www.googleapis.com/auth/youtube.force-ssl', redirect_uri: 'http://localhost').authentication_url

account = Yt::Account.new authorization_code: '4/QKR3CSu_e0Z_HX7nW7FDX0UOJQxg36pklU7FEEBdK9Y', redirect_uri: 'http://localhost'

account.videos.where(q: 'TITLE').each do |video|
  video.delete
end
