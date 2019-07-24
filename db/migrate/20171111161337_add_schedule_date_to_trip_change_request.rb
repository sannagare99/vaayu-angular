class AddScheduleDateToTripChangeRequest < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_change_requests, :schedule_date, :text
  end
end