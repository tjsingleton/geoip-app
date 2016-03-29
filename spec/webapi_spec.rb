require 'spec_helper'

resource 'IP Geolocation' do
  header 'Accept', 'application/json'

  def app
    WebAPI.new
  end

  get '/api/lookup/:query' do
    example 'The geolocation result for an ip address' do
      do_request query: '8.8.8.8'

      expect(status).to eq(200)

      parsed_response = JSON.parse(response_body)
      geolocation = parsed_response.fetch('geolocation')
      expect(geolocation.length).to eq(1)

      meta = parsed_response.fetch('meta')
      expect(meta.fetch('total')).to eq(1)
    end

    example 'The geolocation results for an multiple ip addresses' do
      explanation 'You can get the results for multiple addresses with a comma separated list.'

      do_request query: '8.8.8.8,68.85.173.249'

      expect(status).to eq(200)

      parsed_response = JSON.parse(response_body)
      geolocation = parsed_response.fetch('geolocation')
      expect(geolocation.length).to eq(2)

      meta = parsed_response.fetch('meta')
      expect(meta.fetch('total')).to eq(2)
    end

    example 'The result for an ip that there is no data on' do
      do_request query: '0.0.0.0'

      expect(status).to eq(404)

      parsed_response = JSON.parse(response_body)
      expect(parsed_response.fetch('error')).to eq('No data for IP')
    end

    example 'The result from requesting an invalid ip' do
      do_request query: 'this-is-not-an-ip'

      expect(status).to eq(400)

      parsed_response = JSON.parse(response_body)
      expect(parsed_response.fetch('error')).to eq('Invalid formatted IP')
    end
  end
end
