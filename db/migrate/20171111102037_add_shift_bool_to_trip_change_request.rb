class AddShiftBoolToTripChangeRequest < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_change_requests, :shift, :boolean, :default => false
    add_column :trip_change_requests, :bus_rider, :boolean, :default => false
  end
end