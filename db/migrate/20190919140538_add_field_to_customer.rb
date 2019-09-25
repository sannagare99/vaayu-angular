class AddFieldToCustomer < ActiveRecord::Migration[5.0]
  def change
  	add_column :employee_companies, :customer_code , :string
  	add_column :employee_companies, :reference_no1 , :string
  	add_column :employee_companies, :reference_no2 , :string
  	add_column :employee_companies, :active , :boolean , default: true
  	add_column :employee_companies, :zone , :string
  	add_column :employee_companies, :category , :string
  	add_column :employee_companies, :billing_to , :string

  	add_column :employee_companies, :home_address_contact_name  , :string
  	add_column :employee_companies, :home_address_address_1  , :string
  	add_column :employee_companies, :home_address_address_2  , :string
  	add_column :employee_companies, :home_address_address_3  , :string

  	add_column :employee_companies, :home_address_pin  , :string
  	add_column :employee_companies, :home_address_state  , :string
  	add_column :employee_companies, :home_address_city  , :string
  	add_column :employee_companies, :home_address_phone_1  , :string
  	add_column :employee_companies, :home_address_phone_2  , :string
  	add_column :employee_companies, :home_address_business_area   , :string
  	add_column :employee_companies, :home_address_pan_no  , :string
  	add_column :employee_companies, :home_address_gstin_no  , :string

  end
end
