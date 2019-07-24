class UpdateTripsAddPenalty < ActiveRecord::Migration[5.0]
  def change
  	add_column :trips, :toll, :decimal, default: 0
  	add_column :trips, :penalty, :decimal, default: 0    
  	add_column :trips, :amount, :decimal, default: 0
  	add_column :trips, :paid, :boolean, default: false
  end
end