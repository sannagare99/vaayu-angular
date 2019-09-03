class AddDateOfBirthFieldToDriver < ActiveRecord::Migration[5.0]
  def up
    change_column :drivers, :date_of_birth, :date
  end

  def down
    change_column :drivers, :date_of_birth, :datetime
  end
end
