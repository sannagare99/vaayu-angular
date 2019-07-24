class BaTripInvoice < ApplicationRecord
  belongs_to :trip
  belongs_to :ba_invoice
  belongs_to :ba_vehicle_rate
  belongs_to :ba_zone_rate
  belongs_to :vehicle
end