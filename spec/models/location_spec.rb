require 'rails_helper'

RSpec.describe Location, type: :model do
  #validations
  it { should validate_presence_of(:street) }
  it { should validate_presence_of(:city) }
  it { should validate_presence_of(:state) }
  it { should validate_presence_of(:zip) }
  it { should validate_length_of(:state).is_equal_to(2) }
  it { should validate_length_of(:zip).is_equal_to(5) }
  it { should validate_numericality_of(:zip).only_integer }
  it { should validate_numericality_of(:latitude) }
  it { should validate_numericality_of(:longitude) }

  describe '#set_coordinates' do
    let(:location) { Location.new(street: '315 BOWERY', city: 'NEW YORK', state: 'NY', zip: '10003') }
    before do
      allow(CensusGovService).to receive(:get_coordinates).and_return({ latitude: 40.7265, longitude: -73.9925 })
    end

    it 'sets latitude and longitude' do
      location.set_coordinates
      expect(location.latitude).to eq(40.7265)
      expect(location.longitude).to eq(-73.9925)
    end
  end

  describe '#save_with_coordinates' do
    let(:location) { Location.new(street: '315 BOWERY', city: 'NEW YORK', state: 'NY', zip: '10003') }
    before do
      allow(location).to receive(:valid?).and_return(true)
      allow(location).to receive(:save).and_return(true)
      allow(CensusGovService).to receive(:get_coordinates).and_return({ latitude: 40.7265, longitude: -73.9925 })
    end

    it 'saves the location with coordinates' do
      expect(location.save_with_coordinates).to be_truthy
      expect(location.latitude).to eq(40.7265)
      expect(location.longitude).to eq(-73.9925)
    end
    it 'returns false if the location is invalid' do
      allow(location).to receive(:valid?).and_return(false)
      expect(location.save_with_coordinates).to be_falsey
    end
    it 'rescues from StandardError and logs the error' do
      allow(location).to receive(:valid?).and_raise(StandardError.new("Test error"))
      expect(Rails.logger).to receive(:error).with("Error saving location with coordinates: Test error")
      expect(location.save_with_coordinates).to be_falsey
    end
  end

  describe '.find_by_address' do
    let!(:location) { Location.create(street: '315 Bowery', city: 'New York', state: 'NY', zip: '10003', latitude: 40, longitude: -100) }
    let(:address) { { 'street' => '315 BOWERY', 'city' => 'NEW YORK', 'state' => 'NY', 'zip' => '10003' } }
    
    it 'finds the location by address' do
      found_location = Location.find_by_address(address)
      expect(found_location).to eq(location)
    end
    
    it 'returns nil if no location is found' do
      address = { 'street' => 'Nonexistent', 'city' => 'Nowhere', 'state' => 'ZZ', 'zip' => '00000' }
      found_location = Location.find_by_address(address)
      expect(found_location).to be_nil
    end
  end

  describe '.recent' do
    let!(:ancient_location) { Location.create(street: 'Another St', city: 'Another City', state: 'AC', zip: '67890', latitude: 60, longitude: -130) }
    let!(:old_location) { Location.create(street: 'Oldest St', city: 'Oldest City', state: 'OC', zip: '54321', latitude: 35, longitude: -120) }
    let!(:kinda_recent_location) { Location.create(street: 'Oldest St', city: 'Oldest City', state: 'OC', zip: '54321', latitude: 35, longitude: -120) }
    let!(:recent_location) { Location.create(street: 'Older St', city: 'Older City', state: 'OC', zip: '54321', latitude: 35, longitude: -120) }
    let!(:recenter_location) { Location.create(street: 'Older St', city: 'Older City', state: 'OC', zip: '54321', latitude: 35, longitude: -120) }
    let!(:most_recent_location) { Location.create(street: 'Recent St', city: 'Recent City', state: 'RC', zip: '12345', latitude: 50, longitude: -115) }
    let!(:most_recenter_location) { Location.create(street: 'Old St', city: 'Old City', state: 'OC', zip: '54321', latitude: 35, longitude: -120) }
    
    it 'returns the 5 most recently updated locations' do
      expect(Location.recent).to eq([
        most_recenter_location,
        most_recent_location,
        recenter_location,
        recent_location,
        kinda_recent_location
      ])
    end
  end
end