class AddRemarksInNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :remarks, :string    
  end
end
