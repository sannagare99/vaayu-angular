class AddCancelStatusToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :cancel_status, :text
  end
end