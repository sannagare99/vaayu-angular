class AddAssignDateInTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :trip_assign_date, :datetime
  end
end