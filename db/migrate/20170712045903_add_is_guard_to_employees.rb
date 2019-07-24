class AddIsGuardToEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :is_guard, :boolean, default: false
  end
end
