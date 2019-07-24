class AddDefaultBillingZone < ActiveRecord::Migration[5.0]
  def change
  	remove_column :employees, :billing_zone, :string
    add_column :employees, :billing_zone, :string, default: 'Default'
  end
end