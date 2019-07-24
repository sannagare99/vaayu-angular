class CreateOperators < ActiveRecord::Migration[5.0]
  def change
    create_table :operators do |t|
      t.belongs_to :logistics_company

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
