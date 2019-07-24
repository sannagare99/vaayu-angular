class AddRelationsToTrips < ActiveRecord::Migration[5.0]
  def change
    add_reference :trips, :vehicle, index: true
    add_reference :trips, :site, index: true
  end
end
