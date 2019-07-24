class CreateBusinessAssociates < ActiveRecord::Migration[5.0]
  def change
    create_table :business_associates do |t|

      t.string :admin_f_name
      t.string :admin_m_name
      t.string :admin_l_name
      t.string :admin_email
      t.string :admin_phone

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
