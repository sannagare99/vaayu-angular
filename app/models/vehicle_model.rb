class VehicleModel < ApplicationRecord
	belongs_to :vehicle_category
	validates :make_model, uniqueness: true
end