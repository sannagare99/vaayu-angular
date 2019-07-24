class TripInvoice < ApplicationRecord
  belongs_to :trip
  belongs_to :invoice
  belongs_to :vehicle_rate
  belongs_to :zone_rate
  belongs_to :vehicle
end