class AddTripTypeToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :trip_type, :integer
    add_column :trips, :approximate_duration, :integer
    add_column :trips, :start_date, :datetime

  end
end
