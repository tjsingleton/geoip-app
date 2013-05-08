require 'json'

class WebAPI
  DEFAULT_DB_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data', 'GeoLiteCity.dat'))
  FOUR_OH_FOUR    = [404, {"Content-Type" => "application/json"}, StringIO.new(JSON.generate({error: "No known IP"}))]
  COPYRIGHT_NOTICE = "This product includes GeoLite data created by MaxMind, available from http://www.maxmind.com"

  def initialize(db_path = DEFAULT_DB_PATH)
    @db_path = db_path
  end

  def call(env)
    ip_address = File.basename(env["PATH_INFO"])
    geoip      = Thread.current[:geoip] ||= GeoIP.new(@db_path)

    if struct = geoip.city(ip_address)
      hash = Hash[struct.members.zip(struct.values)]
      json = JSON.generate(hash)
      [200, {"Content-Type" => "application/json", "X-Attribution" => COPYRIGHT_NOTICE}, [json]]
    else
      FOUR_OH_FOUR
    end
  end
end
