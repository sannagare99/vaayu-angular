class AddLandmarkForEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :landmark, :string
  end
end