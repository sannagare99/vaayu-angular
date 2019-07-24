class CreateVehicles < ActiveRecord::Migration[5.0]
  def change
    create_table :vehicles do |t|

      t.belongs_to :driver
      t.belongs_to :business_associate

      t.string :name
      t.string :plate_number
      t.string :make
      t.string :model
      t.string :colour
      t.string :driverid
      t.string :driver_name
      t.string :rc_book_no
      t.date   :registration_date
      t.date   :insurance_date
      t.string :permit_type
      t.date   :permit_validity_date
      t.date   :puc_validity_date
      t.date   :fc_validity_date
      t.boolean :ac
      t.integer :seats, default: 0
      t.string :fuel_type
      t.column :make_year, 'INT UNSIGNED', null: false
      t.column :induction_date, 'INT UNSIGNED'
      t.column :odometer, 'INT UNSIGNED'
      t.boolean :spare_type
      t.boolean :first_aid_kit
      t.string :tyre_condition
      t.string :fuel_level
      t.string :plate_condition
      t.column :device_id, 'INT UNSIGNED'

      t.timestamps
    end
  end
end
