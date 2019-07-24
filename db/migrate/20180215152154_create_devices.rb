class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.string :device_id
      t.string :make
      t.string :model
      t.string :os
      t.string :os_version
      t.integer :status
      t.belongs_to :driver

      t.timestamps
    end
  end
end
