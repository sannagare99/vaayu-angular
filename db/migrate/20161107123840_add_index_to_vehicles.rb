class AddIndexToVehicles < ActiveRecord::Migration[5.0]
  def change
    add_index :vehicles, :plate_number
  end
end
