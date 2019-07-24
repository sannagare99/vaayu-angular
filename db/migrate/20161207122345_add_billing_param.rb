class AddBillingParam < ActiveRecord::Migration[5.0]
  def change
    add_column :business_associates, :invoice_frequency, :integer, default: 0
    add_column :business_associates, :service_tax_percent, :decimal, precision: 5, scale: 4, default: 0
    add_column :business_associates, :swachh_bharat_cess, :decimal, precision: 5, scale: 4, default: 0.002
    add_column :business_associates, :krishi_kalyan_cess, :decimal, precision: 5, scale: 4, default: 0.002

    add_column :employee_companies, :invoice_frequency, :integer, default: 0
    add_column :employee_companies, :service_tax_percent, :decimal, precision: 5, scale: 4,default: 0
    add_column :employee_companies, :swachh_bharat_cess, :decimal, precision: 5, scale: 4, default: 0.002
    add_column :employee_companies, :krishi_kalyan_cess, :decimal, precision: 5, scale: 4, default: 0.002
  end
end