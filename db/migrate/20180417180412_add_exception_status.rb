class AddExceptionStatus < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :exception_status, :string
    add_column :trip_routes, :exception_status, :string
  end
end