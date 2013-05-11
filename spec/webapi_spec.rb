require 'spec_helper'

resource 'IP Geolocation' do
  header "Accept", "application/json"

  def app
    WebAPI.new
  end

  get '/api/lookup/:query' do
    example "The geolocation result for an ip address" do
      do_request query: "8.8.8.8"

      status.should == 200

      parsed_response = JSON.parse(response_body)
      geolocation = parsed_response.fetch("geolocation")
      geolocation.length.should == 1

      meta = parsed_response.fetch("meta")
      meta.fetch("total").should == 1
    end

    example "The geolocation results for an multiple ip addresses" do
      explanation "You can get the results for multiple addresses with a comma separated list."

      do_request query: "8.8.8.8,68.85.173.249"

      status.should == 200

      parsed_response = JSON.parse(response_body)
      geolocation = parsed_response.fetch("geolocation")
      geolocation.length.should == 2

      meta = parsed_response.fetch("meta")
      meta.fetch("total").should == 2
    end

    example "The result for an ip that there is no data on" do
      do_request query: "0.0.0.0"

      status.should == 404

      parsed_response = JSON.parse(response_body)
      parsed_response.fetch("error").should == "No data for IP"
    end


    example "The result from requesting an invalid ip" do
      do_request query: "this-is-not-an-ip"

      status.should == 400

      parsed_response = JSON.parse(response_body)
      parsed_response.fetch("error").should == "Invalid formatted IP"
    end
  end
end
