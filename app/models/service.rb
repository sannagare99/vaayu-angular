class Service < ApplicationRecord  
  belongs_to :site
  has_many :vehicle_rates, :dependent => :destroy
end