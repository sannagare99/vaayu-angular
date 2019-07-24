class AddDriverShouldStartTripParams < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :driver_should_start_trip_time, :datetime
    add_column :trips, :driver_should_start_trip_location, :text
  end
end