class AddCancelExceptionBooleanToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :cancel_exception, :boolean, :default => false
  end
end