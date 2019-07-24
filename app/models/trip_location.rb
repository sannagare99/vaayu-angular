class TripLocation < ApplicationRecord

  belongs_to    :trip
  serialize :location, Hash
  
end