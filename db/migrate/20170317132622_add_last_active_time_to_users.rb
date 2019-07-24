class AddLastActiveTimeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_active_time, :datetime, :default => '2009-01-01 00:00:00'
  end
end