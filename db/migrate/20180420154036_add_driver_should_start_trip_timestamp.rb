class AddDriverShouldStartTripTimestamp < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :driver_should_start_trip_timestamp, :datetime
  end
end