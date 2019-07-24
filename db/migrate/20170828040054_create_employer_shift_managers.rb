class CreateEmployerShiftManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :employer_shift_managers do |t|
      t.integer :employee_company_id

      t.timestamps
    end
  end
end
