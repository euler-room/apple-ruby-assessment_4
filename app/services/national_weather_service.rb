# frozen_string_literal: true
class NationalWeatherService
  include HTTParty
  require 'json'

  base_uri 'https://api.weather.gov'
  
  def self.get_forecast(latitude, longitude, zip)
    Rails.cache.fetch("weather_forecast_#{zip}", expires_in: 10.seconds) do
      location_data = get_location_data(latitude, longitude)
      forecast_url = location_data['properties']['forecast']
      hourly_forecast_url = location_data['properties']['forecastHourly']
      forecast = get_weekly_forecast(forecast_url)
      forecast << get_current_temp(hourly_forecast_url)
    end
  end

  def self.get_current_temp(hourly_forecast_url)
    get_forecast_data(hourly_forecast_url)['properties']['periods'].first['temperature']
  end

  def self.get_weekly_forecast(forecast_url)
    forecast_data = get_forecast_data(forecast_url)['properties']['periods']
    unless forecast_data[0]['isDaytime']
      forecast_data.pop
      forecast_data.shift
    end
    days = forecast_data.in_groups_of(2)
    days.map do |day|
      { icon_afternoon: day[0]['icon'], afternoon: day[0]['name'], high: day[0]['temperature'], icon_night: day[1]['icon'], night: day[1]['name'], low: day[1]['temperature'] }
    end
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
