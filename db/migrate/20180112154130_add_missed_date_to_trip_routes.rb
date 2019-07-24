class AddMissedDateToTripRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :missed_date, :datetime
  end
end