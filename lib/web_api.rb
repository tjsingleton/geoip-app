require 'json'
require 'resolv'

class WebAPI
  DEFAULT_DB_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'GeoLiteCity.dat'))
  FOUR_OH_FOUR    = [404, {"Content-Type" => "application/json"}, [JSON.generate({error: "No known IP"})]]
  INVALID         = [400, {"Content-Type" => "application/json"}, [JSON.generate({error: "Invalid formatted IP"})]]
  COPYRIGHT_NOTICE = "This product includes GeoLite data created by MaxMind, available from http://www.maxmind.com"

  def initialize(db_path = DEFAULT_DB_PATH)
    @db_path = db_path
  end

  def call(env)
    geoip     = Thread.current[:geoip] ||= GeoIP.new(@db_path)
    addresses = File.basename(env["PATH_INFO"]).split("+")

    responses = addresses.map do |ip|
      break(:invalid) unless Resolv::IPv4::Regex.match(ip)

      if (geolocation = geoip.city(ip))
        Hash[geolocation.members.zip(geolocation.values)]
      end
    end

    if responses == :invalid
      return INVALID
    end

    responses.compact!
    if responses.empty?
      FOUR_OH_FOUR
    else
      json = JSON.generate({geolocation: responses, meta: {total: responses.count}})
      [200, {"Content-Type" => "application/json", "X-Attribution" => COPYRIGHT_NOTICE}, [json]]
    end
  end
end
