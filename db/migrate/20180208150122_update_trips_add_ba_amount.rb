class UpdateTripsAddBaAmount < ActiveRecord::Migration[5.0]
  def change
  	add_column :trips, :ba_toll, :decimal, default: 0
  	add_column :trips, :ba_penalty, :decimal, default: 0    
  	add_column :trips, :ba_amount, :decimal, default: 0
  	add_column :trips, :ba_paid, :boolean, default: false
  end
end