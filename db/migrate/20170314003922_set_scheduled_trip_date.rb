class SetScheduledTripDate < ActiveRecord::Migration
  def self.up
    Trip.update_all("scheduled_date=planned_date")
  end

  def self.down
  end
end