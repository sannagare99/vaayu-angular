class BaVehicleRate < ApplicationRecord
  belongs_to :ba_service
  has_many :ba_zone_rates, :dependent => :destroy
  has_many :ba_package_rates, :dependent => :destroy
end