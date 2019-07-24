class DriverFirstPickup < ApplicationRecord
  belongs_to    :trip
  belongs_to    :driver
end