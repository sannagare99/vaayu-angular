class CreateEmployees < ActiveRecord::Migration[5.0]
  def change
    create_table :employees do |t|

      t.belongs_to :employee_company
      t.belongs_to :site
      t.belongs_to :zone

      t.string  :employee_id
      t.integer :gender
      t.string  :home_address
      t.decimal :home_address_latitude, precision: 10, scale: 6
      t.decimal :home_address_longitude, precision: 10, scale: 6

      t.integer :distance_to_site

      t.date    :date_of_birth
      t.string  :managers_employee_id
      t.string  :managers_email_id

      t.timestamps
    end
  end
end
