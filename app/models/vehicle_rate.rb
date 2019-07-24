class VehicleRate < ApplicationRecord
  belongs_to :service
  has_many :zone_rates, :dependent => :destroy
  has_many :package_rates, :dependent => :destroy
end