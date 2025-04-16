class LocationsController < ApplicationController
  def new
    @location = Location.new
  end

  def create
    @location = Location.find_by_address(location_params) || Location.new(location_params)
    
    unless @location.latitude && @location.longitude
      success = @location.save_with_coordinates
      unless success
        flash.now[:alert] = "Could not find coordinates for this address."
        return render :new, status: :unprocessable_entity
      end
    end

    if @location.save
      redirect_to location_path(@location)
    else
      flash.now[:alert] = @location.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @location = Location.find(params[:id])
    if @location
      @forecast = Rails.cache.fetch("weather_forecast_#{@location.zip}")
      if @forecast
        @cached_result = true
      else
        @forecast = NationalWeatherService.get_forecast(@location.latitude, @location.longitude, @location.zip)
        @cached_result = false
      end
      render :show
    else
      flash[:alert] = "Location not found."
      redirect_to action: :new
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Location not found."
    redirect_to action: :new
  end

  private

  def location_params
    params.require(:location).permit(:street, :city, :state, :zip)
  rescue ActionController::ParameterMissing
    flash[:alert] = "Please provide location details."
    redirect_to action: :new and return
  end
end