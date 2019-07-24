class BusTrip < ApplicationRecord
  extend AdditionalFinders
  include AASM
  DATATABLE_PREFIX = 'bus_trip'

  has_many :bus_trip_routes, dependent: :destroy

  aasm :column => :status do
    state :operating, :initial => true
    state :stopped

    event :stop do
      transitions :to => :stopped
    end

    event :activate do
    	transitions :to => :operating
    end
  end  
end