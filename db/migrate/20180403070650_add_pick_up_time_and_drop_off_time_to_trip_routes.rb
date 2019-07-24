class AddPickUpTimeAndDropOffTimeToTripRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :pick_up_time, :datetime
    add_column :trip_routes, :drop_off_time, :datetime
  end
end
