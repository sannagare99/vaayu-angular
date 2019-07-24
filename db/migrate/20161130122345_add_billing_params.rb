class AddBillingParams < ActiveRecord::Migration[5.0]
  def change
    add_column :business_associates, :standard_price, :decimal, precision: 12, scale: 2
    add_column :business_associates, :pay_period, :integer, default: 0

    add_column :business_associates, :time_on_duty_limit, :integer
    add_column :business_associates, :distance_limit, :decimal, precision: 8, scale: 2

    add_column :business_associates, :rate_by_time, :decimal, precision: 8, scale: 2
    add_column :business_associates, :rate_by_distance, :decimal, precision: 8, scale: 2


    add_column :employee_companies, :standard_price, :decimal, precision: 12, scale: 2
    add_column :employee_companies, :pay_period, :integer, default: 0

    add_column :employee_companies, :time_on_duty_limit, :integer
    add_column :employee_companies, :distance_limit, :decimal, precision: 8, scale: 2

    add_column :employee_companies, :rate_by_time, :decimal, precision: 8, scale: 2
    add_column :employee_companies, :rate_by_distance, :decimal, precision: 8, scale: 2

  end
end