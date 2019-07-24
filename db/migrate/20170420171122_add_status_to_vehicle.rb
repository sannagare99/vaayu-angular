class AddStatusToVehicle < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicles, :status, :text
  end
end