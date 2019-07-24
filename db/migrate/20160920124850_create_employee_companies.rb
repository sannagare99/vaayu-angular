class CreateEmployeeCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_companies do |t|
      t.belongs_to :logistics_company

      t.string :name

      t.timestamps
    end
  end
end
