class AddFieldForDriverVerify < ActiveRecord::Migration[5.0]
  def change
  	add_column :trips, :verified_driver_image, :boolean, default: false
  end
end