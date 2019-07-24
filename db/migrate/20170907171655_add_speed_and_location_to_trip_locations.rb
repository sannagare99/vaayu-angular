class AddSpeedAndLocationToTripLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_locations, :distance, :integer
    add_column :trip_locations, :speed, :text
  end
end