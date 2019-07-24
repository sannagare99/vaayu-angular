class AddSequenceToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :sequence, :integer
  end
end
