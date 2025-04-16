# frozen_string_literal: true
class CensusGovService
  include HTTParty
  require 'json'
  
  base_uri 'https://geocoding.geo.census.gov/geocoder/locations'

  def self.get_coordinates(location)
    location_data = get_location_data(location)
    return nil unless location_data && location_data['coordinates']

    coordinates = {
      latitude: location_data['coordinates']['y'],
      longitude: location_data['coordinates']['x']
    }

    # Validate coordinates are present and numeric
    if coordinates[:latitude].present? && coordinates[:longitude].present? &&
       coordinates[:latitude].is_a?(Numeric) && coordinates[:longitude].is_a?(Numeric)
      coordinates
    else
      Rails.logger.error "Invalid coordinates received: #{coordinates.inspect}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Error getting coordinates: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
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

    unless response.success?
      Rails.logger.error "Census API request failed: #{response.code} - #{response.body}"
      return nil
    end

    begin
      parsed_response = response.parsed_response
      address_matches = parsed_response.dig('result', 'addressMatches')

      if address_matches&.any?
        address_matches.first
      else
        Rails.logger.error "No matching addresses found for: #{location.attributes}"
        nil
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse Census API response: #{e.message}"
      Rails.logger.error "Response body: #{response.body}"
      nil
    end
  rescue HTTParty::Error => e
    Rails.logger.error "HTTP request failed: #{e.class} - #{e.message}"
    nil
  rescue StandardError => e
    Rails.logger.error "Unexpected error in get_location_data: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    nil
  end
end
