require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'is valid with valid attributes' do
    location = Location.new(name: 'Test Location', latitude: 0.0, longitude: 0.0)
    expect(location).to be_valid
  end

  it 'is not valid without a name' do
    location = Location.new(name: nil)
    expect(location).to_not be_valid
  end

  it 'is not valid without latitude' do
    location = Location.new(latitude: nil)
    expect(location).to_not be_valid
  end

  it 'is not valid without longitude' do
    location = Location.new(longitude: nil)
    expect(location).to_not be_valid
  end
end