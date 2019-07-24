class AddEmployeeTripDriverRequestRelationToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_reference :notifications, :employee_trip, index: true
    add_reference :notifications, :driver_request, index: true
  end
end