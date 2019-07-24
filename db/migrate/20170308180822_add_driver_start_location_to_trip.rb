class AddDriverStartLocationToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :start_location, :text
  end
end