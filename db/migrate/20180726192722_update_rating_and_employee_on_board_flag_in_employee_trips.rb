class UpdateRatingAndEmployeeOnBoardFlagInEmployeeTrips < ActiveRecord::Migration[5.0]
  def change
    rename_column :employee_trips, :is_trip_rated, :is_rating_screen_shown
    rename_column :employee_trips, :is_employee_on_board, :is_still_on_board_screen_shown
  end
end