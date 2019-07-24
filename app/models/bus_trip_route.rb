require 'services/google_service'

class BusTripRoute < ApplicationRecord
  include AASM
  belongs_to :bus_trip
  before_validation :set_route_location

  def create_new(name, address, order, bus_trip)
  	self.create!({
  		:stop_name => name,
  		:stop_address => address,
  		:stop_order => order,
  		:bus_trip => bus_trip
  	})
  end

  def bus_trip_location
    [ stop_latitude, stop_longitude ]
  end

  # Update home address coordinates on every save
  def set_route_location
    self.stop_latitude = nil
    self.stop_longitude = nil

    # Geocoding an address
    results = stop_address.present? ? GoogleService.new.geocode(stop_address).first : nil

    unless results.nil? || ! results.key?(:geometry)
      coordinates = results[:geometry][:location]
      self.stop_latitude = coordinates[:lat]
      self.stop_longitude = coordinates[:lng]
    end

  end  
end
