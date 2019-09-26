class VehicleCategory < ApplicationRecord
	validates :category_name, presence: true, uniqueness: true
end