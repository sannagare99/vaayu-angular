class AddCallSidToNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :call_sid, :text
  end
end	