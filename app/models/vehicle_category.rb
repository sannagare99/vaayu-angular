class VehicleCategory < ApplicationRecord
	validates :make_model, presence: true, uniqueness: true
end
