class AddNodalNameInEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :nodal_name, :string    
  end
end
