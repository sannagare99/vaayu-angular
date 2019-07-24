class AddResolvedStatusToNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :resolved_status, :boolean, :default => true
  end
end