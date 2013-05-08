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
    JSON.parse(last_response.body.to_s).should == {
        "geolocation" => [{"request"=>"174.36.207.186", "ip"=>"174.36.207.186", "country_code2"=>"US", "country_code3"=>"USA", "country_name"=>"United States", "continent_code"=>"NA", "region_name"=>"DC", "city_name"=>"Washington", "postal_code"=>"", "latitude"=>38.89510000000001, "longitude"=>-77.0364, "dma_code"=>511, "area_code"=>202, "timezone"=>"America/New_York"}],
        "meta" => {"total" => 1}
    }
  end

  it "looks up multiple ip addresses" do
    get "/api/lookup/174.36.207.186+74.125.137.138"

    last_response.status.should == 200
    JSON.parse(last_response.body.to_s).should == {
        "geolocation" => [
            {"request"=>"174.36.207.186", "ip"=>"174.36.207.186", "country_code2"=>"US", "country_code3"=>"USA", "country_name"=>"United States", "continent_code"=>"NA", "region_name"=>"DC", "city_name"=>"Washington", "postal_code"=>"", "latitude"=>38.89510000000001, "longitude"=>-77.0364, "dma_code"=>511, "area_code"=>202, "timezone"=>"America/New_York"},
            {"request"=>"74.125.137.138", "ip"=>"74.125.137.138", "country_code2"=>"US", "country_code3"=>"USA", "country_name"=>"United States", "continent_code"=>"NA", "region_name"=>"CA", "city_name"=>"Mountain View", "postal_code"=>"94043", "latitude"=>37.41919999999999, "longitude"=>-122.0574, "dma_code"=>807, "area_code"=>650, "timezone"=>"America/Los_Angeles"},
        ],
        "meta" => {"total" => 2}
    }
  end

  it "404 when there is no data" do
    get "/api/lookup/0.0.0.0"

    last_response.status.should == 404
    JSON.parse(last_response.body.to_s).should == {"error" => "No known IP"}
  end

  it 'rejects invalid formatted ip addresses' do
    get "/api/lookup/this-is-not-an-ip"

    last_response.status.should == 400
    JSON.parse(last_response.body.to_s).should == {"error" => "Invalid formatted IP"}
  end
end
