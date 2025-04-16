class Location < ApplicationRecord
  validates :zip , presence: true, length: { is: 5 }, numericality: { only_integer: true }
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :city, presence: true
  validates :state, presence: true, length: { is: 2 }
  validates :street, presence: true

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
    Rails.logger.error "Error in save_with_coordinates: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  def self.find_by_address(params)
    normalized_params = params.transform_values(&:upcase)
    
    where(
      street: normalized_params[:street],
      city: normalized_params[:city],
      state: normalized_params[:state],
      zip: normalized_params[:zip]
    ).first
  end

  def self.recent
    order(updated_at: :desc).limit(5)
  end
end
