class Location < ApplicationRecord
  validates :zip , presence: true, length: { is: 5 }, numericality: { only_integer: true }
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :city, presence: true
  validates :state, presence: true, length: { is: 2 }
  validates :street, presence: true
  
  before_save :normalize_data

  def set_coordinates
    coordinates = CensusGovService.get_coordinates(self)
    
    if coordinates
      self.latitude = coordinates[:latitude]
      self.longitude = coordinates[:longitude]
      Rails.logger.info "Coordinates set to: lat=#{latitude}, long=#{longitude}"
      true
    else
      Rails.logger.error "Failed to get coordinates from CensusGovService"
      false
    end
  rescue StandardError => e
    Rails.logger.error "Error in set_coordinates: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  def save_with_coordinates
    return false unless set_coordinates
    
    if valid?
      save
      true
    else
      Rails.logger.error "Validation failed: #{errors.full_messages.join(', ')}"
      false
    end
  rescue StandardError => e
    Rails.logger.error "Error saving location with coordinates: #{e.message}"
    false
  end

  def self.find_by_address(params)
  
    where(
      street: params['street'].to_s.downcase.titleize,
      city: params['city'].to_s.downcase.titleize,
      state: params['state'].to_s.upcase,
      zip: params['zip'].to_s
    ).first
  end

  def self.recent
    order(updated_at: :desc).limit(5)
  end

  
  def normalize_data

    self.street = street.to_s.downcase.titleize
    self.city = city.to_s.downcase.titleize
    self.state = state.to_s.upcase
    self.zip = zip.to_s
    self.latitude = latitude&.to_f
    self.longitude = longitude&.to_f
   
  end
end
