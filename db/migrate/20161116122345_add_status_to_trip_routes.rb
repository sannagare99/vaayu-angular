class AddStatusToTripRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :status, :string
  end
end