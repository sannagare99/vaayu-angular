class AddDriverActionDatesToTripRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :driver_arrived_date, :datetime
    add_column :trip_routes, :on_board_date, :datetime
    add_column :trip_routes, :completed_date, :datetime
  end
end
