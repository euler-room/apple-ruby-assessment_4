class Location < ApplicationRecord
  validates :zip , presence: true, length: { is: 5 }, numericality: { only_integer: true }
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :city, presence: true
  validates :state, presence: true, length: { is: 2 }, format: { with: /\A[A-Z]{2}\z/, message: "must be two uppercase letters" }
  validates :street, presence: true

  def set_coordinates
    coordinates = CensusGovService.get_coordinates(self)
    self.latitude = coordinates[:latitude]
    self.longitude = coordinates[:longitude]
  end

  def save_with_coordinates
    set_coordinates
    if valid?
      save
      self
    else
      false
    end
  rescue StandardError => e
    Rails.logger.error "Error saving location with coordinates: #{e.message}"
    false
  end

  def self.find_by_address(address)
    address.each{ |k, v| v.upcase!}
    where(
      street: address['street'],
      city: address['city'],
      state: address['state'],
      zip: address['zip']
    ).first
  end

  def self.recent
    order(updated_at: :desc).limit(5)
  end
end
