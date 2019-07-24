class AddScheduledTripDate < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :scheduled_date, :datetime
  end
end