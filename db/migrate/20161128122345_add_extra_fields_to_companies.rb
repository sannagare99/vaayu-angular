class AddExtraFieldsToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :business_associates, :name, :string

    add_column :employee_companies, :pan, :string
    add_column :employee_companies, :tan, :string
    add_column :employee_companies, :business_type, :string
    add_column :employee_companies, :service_tax_no, :string
    add_column :employee_companies, :hq_address, :string

    add_column :logistics_companies, :pan, :string
    add_column :logistics_companies, :tan, :string
    add_column :logistics_companies, :business_type, :string
    add_column :logistics_companies, :service_tax_no, :string
    add_column :logistics_companies, :hq_address, :string

  end
end