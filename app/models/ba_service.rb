class BaService < ApplicationRecord  
  belongs_to :business_associate
  has_many :ba_vehicle_rates, :dependent => :destroy
end