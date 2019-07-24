class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|

      t.belongs_to :driver
      t.belongs_to :employee
      t.belongs_to :trip
      t.string :message
      t.integer :type
      t.integer :status

      t.timestamps
    end
  end
end
