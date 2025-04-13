require 'rails_helper'

RSpec.describe CensusGovService do
  describe '.get_coordinates' do
    let(:address) do
      {
        street: '315 Bowery',
        city: 'New York',
        state: 'NY',
        zip: '10003'
      }
    end
    before do
      allow(CensusGovService).to receive(:get_location_data).and_return(
        { 
          'coordinates' => {
            'x' => -73.9925,
            'y' => 40.7265
          }
        }
      )
    end
    it 'returns latitude and longitude for a matched address' do
      expect(CensusGovService.get_coordinates(address)).to eq({ latitude: -73.9925, longitude: 40.7265 })
    end
  end

  describe '.get_location_data' do
    let(:address) do
      {
        street: '315 Bowery',
        city: 'New York',
        state: 'NY',
        zip: '10003'
      }
    end
    let(:response) { CensusGovService.get_location_data(address) }

    it 'returns location_data for a matched address' do
      VCR.use_cassette('census_gov_service/get_location_data') do
        response
      end
        expect(response).to include('coordinates')
    end

    let(:invalid_address) do
      {
        street: 'Existential',
        city: 'Crisis',
        state: 'XO',
        zip: '00000'
      }
    end
    it 'raises an error for an invalid address' do
      VCR.use_cassette('census_gov_service/get_location_data_invalid') do
        expect {
          CensusGovService.get_location_data(invalid_address)
        }.to raise_error(RuntimeError, /Error: No Matching Addresses/)
      end
    end
  end  
end
