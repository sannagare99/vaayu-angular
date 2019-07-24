class ChangeStatusInDrivers < ActiveRecord::Migration[5.0]
  def up
    change_column :drivers, :status, :string
  end

  def down
    change_column :drivers, :status, :integer
  end
end
