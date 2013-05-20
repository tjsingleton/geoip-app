require 'bundler/setup'
Bundler.require(:default, :test)

require 'pathname'
require_relative '../lib/web_api'

require 'rspec_api_documentation/dsl'

class PrettyJSON
  def self.dump(object)
    JSON.pretty_generate(object, {indent: "  "})
  end
end

WebAPI.coder = PrettyJSON

RspecApiDocumentation.configure do |config|
  config.curl_host = "http://geoip-app.herokuapp.com"
  config.docs_dir = Pathname.new(File.expand_path(File.join(File.dirname(__FILE__), '../public/doc')))
end

