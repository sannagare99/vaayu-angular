# Creates an index for ScheduledDate and Status for the Trips table
class CreateIndexForScheduledDateAndStatusOnTrips < ActiveRecord::Migration[5.0]
  def change
    add_index :trips, :status
    add_index :trips, :scheduled_date
  end
end
