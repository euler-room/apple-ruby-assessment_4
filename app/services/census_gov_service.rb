# frozen_string_literal: true
class CensusGovService
  include HTTParty
  require 'json'
  
  base_uri 'https://geocoding.geo.census.gov/geocoder/locations'

  def self.get_coordinates(location)
    location_data = get_location_data(location)
    { latitude: location_data['coordinates']['y'], longitude: location_data['coordinates']['x'] }
  end

  # fetches coordinates for a given location instance: 
  # { 
  #   street: '123 Main St',
  #   city: 'Anytown',
  #   state: 'CA',
  #   zip: '12345'
  # }

  # Call to Census.gov API returns in the following format:
  # {
  #   "result": {
  #     "addressMatches": [
  #       {
  #         "coordinates": {
  #           "x": -123.6054803,
  #           "y": 45.2397485
  #         }
  #         "addressComponents": {
  #           "state": "CA",
  #           "city": "Anytown",
  #           "zip": "12345",
  #           "street": "123 Main St"
  #         }
  #       }
  #     ]
  #   }
  # }
  def self.get_location_data(location)
    response = get('/address', query: {
      street: location.street,
      city: location.city,
      state: location.state,
      zip: location.zip,
      benchmark: 4,
      format: 'json'
    })
    if response['result']['addressMatches'].any?
      response.parsed_response['result']['addressMatches'].first
    else
      raise "Error: No Matching Addresses"
    end
  end
end
