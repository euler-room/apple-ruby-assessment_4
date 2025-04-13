require 'rails_helper'

RSpec.describe NationalWeatherService do
  describe '.get_forecast' do
    let(:latitude) { 45.2397485 }
    let(:longitude) { -123.6054803 }
    let(:forecast_uri) { 'https://forecast.uri' }
    before do
      allow(NationalWeatherService).to receive(:get_location_data).and_return(
        'properties' => {
          'forecast' => forecast_uri
        }
      )
      allow(NationalWeatherService).to receive(:get_forecast_data).and_return(
        'properties' => {
          'periods' => []
        }
      )
    end

    it 'calls get_location_data and get_forecast_data' do
      expect(NationalWeatherService).to receive(:get_location_data).once
      expect(NationalWeatherService).to receive(:get_forecast_data).once
      NationalWeatherService.get_forecast(latitude, longitude)
    end
  end

  describe '.get_location_data' do
    let(:latitude) { 45.2397485 }
    let(:longitude) { -123.6054803 }
    let(:response) { NationalWeatherService.get_location_data(latitude, longitude) }
    # only check for successful response and format (we cant controll NWS.gov's accuracy)
    it 'returns location data' do
      VCR.use_cassette('national_weather_service/get_location_data') do
        response
      end
      expect(response).to be_a(Hash)
      expect(response).to include('properties')
      expect(response['properties']).to include('forecast')
    end

    # check for errors with controlled inputs
    let(:invalid_latitude) { 999 }
    let(:invalid_longitude) { 999 }
    it 'raises an error for invalid coordinates' do
      VCR.use_cassette('national_weather_service/get_location_data_invalid') do
        expect {
          NationalWeatherService.get_location_data(invalid_latitude, invalid_longitude)
        }.to raise_error(RuntimeError, /Error fetching location data: 400 - Bad Request/)
      end
    end
  end

  describe '.get_forecast_data' do
    let(:forecast_uri) { 'https://api.weather.gov/gridpoints/OTX/149,57/forecast' }
    let(:response) { NationalWeatherService.get_forecast_data(forecast_uri) }

    # only check for successful response and format (we cant controll NWS.gov's accuracy)
    it 'returns forecast data' do
      VCR.use_cassette('national_weather_service/get_forecast_data') do
        response
      end
      expect(response).to be_a(Hash)
      expect(response).to include('properties')
      expect(response['properties']).to include('periods')
    end
  end
end
