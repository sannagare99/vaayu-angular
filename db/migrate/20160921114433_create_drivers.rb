class CreateDrivers < ActiveRecord::Migration[5.0]
  def change
    create_table :drivers do |t|

      t.belongs_to :business_associate
      t.belongs_to :logistics_company
      t.belongs_to :site

      t.integer :status

      t.string :badge_number
      t.date   :badge_issue_date
      t.date   :badge_expire_date
      t.string :local_address
      t.string :permanent_address
      t.string :aadhaar_number
      t.string :aadhaar_mobile_number
      t.string :licence_number
      t.date   :licence_validity
      t.boolean :verified_by_police
      t.boolean :uniform
      t.boolean :licence
      t.boolean :badge
      
      t.timestamps
    end
  end
end
