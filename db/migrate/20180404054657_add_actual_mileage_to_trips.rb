class AddActualMileageToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :actual_mileage, :integer, default: 0
  end
end
