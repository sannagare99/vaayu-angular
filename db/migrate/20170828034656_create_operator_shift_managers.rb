class CreateOperatorShiftManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :operator_shift_managers do |t|
      t.integer :logistics_company_id
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
