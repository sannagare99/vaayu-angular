class AddRegistrationStepsToVechile < ActiveRecord::Migration[5.0]
  def change
    add_column :vehicles, :registration_steps, :string
  end
end
