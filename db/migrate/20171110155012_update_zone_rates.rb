class UpdateZoneRates < ActiveRecord::Migration[5.0]
  def change
    add_column :zone_rates, :name, :text
  end
end