class AddMoveToNextStepTimeLocation < ActiveRecord::Migration[5.0]
  def change
    add_column :trip_routes, :move_to_next_step_date, :datetime
    add_column :trip_routes, :move_to_next_step_location, :text
  end
end