class ChangeNotificationTypeColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :notifications, :type, :receiver
  end
end
