require 'bundler/setup'
Bundler.require(:default)

require 'rack/content_length'
require 'rack/static'

require './lib/web_api'

use Rack::ContentLength
use Rack::Static, urls: ["/stylesheets", '/javascripts', '/images'], root: 'public', :index =>
'index.html'

map '/api/lookup' do
  run WebAPI.new
end

