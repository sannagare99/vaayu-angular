class AddSortColumnInDrivers < ActiveRecord::Migration[5.0]
  def change
    add_column :drivers, :sort_status, :integer, default: -1    
  end
end