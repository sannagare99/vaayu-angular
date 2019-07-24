class AddZoneRateToEmployees < ActiveRecord::Migration[5.0]
  def change
    add_column :employees, :billing_zone, :string
  end
end
