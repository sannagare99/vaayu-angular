class ChangeInductionInVehicles < ActiveRecord::Migration[5.0]
  def change
  	remove_column :vehicles, :induction_date
    add_column :vehicles, :induction_date, :date
  end
end
