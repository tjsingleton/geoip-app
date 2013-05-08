require 'uri'
require 'net/http'
require 'zlib'

DATABASE_URL    = URI.parse('http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz')
DATABASE_PATH   = 'data/GeoLiteCity.dat'
GZIP_WBITS      = (Zlib::MAX_WBITS + 32)

task :update_database do
  Net::HTTP.start(DATABASE_URL.host, DATABASE_URL.port) do |http|
    request = Net::HTTP::Get.new(DATABASE_URL.to_s)
    zlib    = Zlib::Inflate.new(GZIP_WBITS)

    File.open(DATABASE_PATH, 'w+') do |out|
      http.request(request) do |response|
        response.read_body do |body_chunk|
          out << zlib.inflate(body_chunk)
        end
      end
    end

    zlib.finish
  end
end
