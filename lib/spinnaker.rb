require 'json'
require 'httparty'

class Spinnaker
  class << Spinnaker
    def retrieve_json(full_url)
      begin
        auth = {username: ENV['DASHBOARD_USER'], password: ENV['DASHBOARD_PASSWORD']}
        response = HTTParty.get(full_url, basic_auth: auth)
        return response
      rescue => e
        raise SpinnakerConnectionException, "Could not get resposne from Spinnaker #{full_url}, details: #{e}"
      end
    end
  end
end

class SpinnakerConnectionException < StandardError
end