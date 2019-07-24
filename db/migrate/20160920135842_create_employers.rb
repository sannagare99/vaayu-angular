class CreateEmployers < ActiveRecord::Migration[5.0]
  def change
    create_table :employers do |t|

      t.belongs_to :employee_company

      t.string :legal_name
      t.string :pan
      t.string :tan
      t.string :business_type
      t.string :service_tax_no
      t.string :hq_address

      t.timestamps
    end
  end
end
