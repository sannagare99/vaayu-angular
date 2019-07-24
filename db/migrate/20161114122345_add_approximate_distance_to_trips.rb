class AddApproximateDistanceToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :approximate_distance, :integer
  end
end
