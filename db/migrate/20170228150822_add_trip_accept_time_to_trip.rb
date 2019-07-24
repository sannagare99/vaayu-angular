class AddTripAcceptTimeToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :trip_accept_time, :datetime
  end
end