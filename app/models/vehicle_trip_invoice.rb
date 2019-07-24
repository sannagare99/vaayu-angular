class VehicleTripInvoice < ApplicationRecord
	belongs_to :vehicle
	belongs_to :trip
	belongs_to :trip_invoice
	belongs_to :ba_trip_invoice
end