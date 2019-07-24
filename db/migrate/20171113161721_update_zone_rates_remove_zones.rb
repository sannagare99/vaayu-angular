class UpdateZoneRatesRemoveZones < ActiveRecord::Migration[5.0]
  def change
    remove_reference :zone_rates, :zone
  end
end