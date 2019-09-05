class AddRegistrationStepsToDriver < ActiveRecord::Migration[5.0]
  def change
  	add_column :drivers, :registration_steps, :string
  end
end
