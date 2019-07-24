class AddRatingAndEmployeeOnBoardFlagInEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_trips, :is_trip_rated, :boolean, default: false
    add_column :employee_trips, :is_employee_on_board, :boolean, default: false
  end
end