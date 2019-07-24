class AddNodalAddressInEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :nodal_address, :string
    add_column :employees, :nodal_address_latitude, :decimal, precision: 10, scale: 6
    add_column :employees, :nodal_address_longitude, :decimal, precision: 10, scale: 6
  end
end
