class AddAssignRequestExpiredDateToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :assign_request_expired_date, :datetime
  end
end
