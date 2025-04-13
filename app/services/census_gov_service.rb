# frozen_string_literal: true
class CensusGovService
  include HTTParty
  require 'json'
  
  base_uri 'https://geocoding.geo.census.gov/geocoder/locations'

  def self.get_coordinates(address)
    location_data = get_location_data(address)
    { latitude: location_data['coordinates']['x'], longitude: location_data['coordinates']['y'] }
  end

  # fetches coordinates for a given address: 
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
  def self.get_location_data(address)
    response = get('/address', query: {
      street: address[:street],
      city: address[:city],
      state: address[:state],
      zip: address[:zip],
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
