class AddReporterInNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :reporter, :string    
  end
end
