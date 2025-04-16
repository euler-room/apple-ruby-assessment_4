module LocationHelper 
  # Returns a formatted address string for the given location
  # Example: "123 Main St, Springfield, IL 62704"
  def formatted_address(location)
    "#{location.street.titleize}, #{location.city.titleize}, #{location.state} #{location.zip}"
  end
end