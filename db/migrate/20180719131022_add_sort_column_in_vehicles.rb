class AddSortColumnInVehicles < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicles, :sort_status, :integer, default: -1    
  end
end