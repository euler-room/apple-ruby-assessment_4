# frozen_string_literal: true
class NationalWeatherService
  include HTTParty
  require 'json'

  base_uri 'https://api.weather.gov'
  
  def self.get_forecast(latitude, longitude)
    location_data = get_location_data(latitude, longitude)
    forecast_url = location_data['properties']['forecast']
    forecast = get_forecast_data(forecast_url)

  end

  def self.get_location_data(latitude, longitude)
    response = get("/points/#{latitude},#{longitude}")
    if response.success?
      JSON.parse(response.parsed_response)
    else
      raise "Error fetching location data: #{response.code} - #{response.message}"
    end
  end

  def self.get_forecast_data(forecast_uri)
    response = get(forecast_uri)
    if response.success?
      JSON.parse(response.parsed_response)
    else
      raise "Error fetching forecast data: #{response.code} - #{response.message}"
    end
  end

end
