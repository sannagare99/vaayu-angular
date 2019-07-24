class AddNewStatusToNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :new_notification, :boolean, :default => false
  end
end