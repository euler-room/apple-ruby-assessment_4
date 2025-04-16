class LocationsController < ApplicationController
  def new
    @location = Location.new()
  end

  def create
    @location = Location.find_by_address(location_params) || Location.new(location_params)
    unless @location.latitude && @location.longitude
      @location.save_with_coordinates
    end
    if @location.valid?
      redirect_to action: :show, id: @location.id
    else
      flash.now[:alert] = "Location not found."
      render :new
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
        @cached_resuilt = false
      end
      render :show
    else
      flash.now[:alert] = "Location not found."
      redirect_to action: :new
    end
  end

  private

  def location_params
    params.require(:location).permit(:street, :city, :state, :zip)
  rescue ActionController::ParameterMissing
    flash[:alert] = "Please provide location details."
    redirect_to action: :new and return
  end
end