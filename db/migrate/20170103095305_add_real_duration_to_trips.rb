class AddRealDurationToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :real_duration, :integer
    add_column :trips, :completed_date, :datetime
  end
end
