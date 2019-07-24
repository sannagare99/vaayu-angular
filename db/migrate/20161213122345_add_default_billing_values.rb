class AddDefaultBillingValues < ActiveRecord::Migration[5.0]
  def change

    change_column :business_associates, :standard_price, :decimal, default: 0
    change_column :business_associates, :time_on_duty_limit, :integer, default: 0
    change_column :business_associates, :distance_limit, :integer, default: 0
    change_column :business_associates, :rate_by_time, :decimal, default: 0
    change_column :business_associates, :rate_by_distance, :decimal, default: 0


    change_column :employee_companies, :standard_price, :decimal, default: 0
    change_column :employee_companies, :time_on_duty_limit, :integer, default: 0
    change_column :employee_companies, :distance_limit, :integer, default: 0
    change_column :employee_companies, :rate_by_time, :decimal, default: 0
    change_column :employee_companies, :rate_by_distance, :decimal, default: 0
  end
end