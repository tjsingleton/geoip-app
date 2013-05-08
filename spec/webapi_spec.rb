require 'bundler/setup'
Bundler.require(:default, :test)

require_relative '../lib/web_api'

describe WebAPI do
  include Rack::Test::Methods

  def app
    WebAPI.new
  end

  it "looks up an ip address" do
    get "/api/lookup/174.36.207.186"

    last_response.status.should == 200
    JSON.parse(last_response.body.to_s).should == {"request"=>"174.36.207.186", "ip"=>"174.36.207.186", "country_code2"=>"US", "country_code3"=>"USA", "country_name"=>"United States", "continent_code"=>"NA", "region_name"=>"DC", "city_name"=>"Washington", "postal_code"=>"", "latitude"=>38.89510000000001, "longitude"=>-77.0364, "dma_code"=>511, "area_code"=>202, "timezone"=>"America/New_York"}
  end

  it "404 when there is no data" do
    get "/api/lookup/0.0.0.0"

    last_response.status.should == 404
    JSON.parse(last_response.body.to_s).should == {"error" => "No known IP"}
  end
end
