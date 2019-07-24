class AddOlaParamsToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :book_ola, :boolean, :default => false
    add_column :trips, :ola_fare, :text
  end
end