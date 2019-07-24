class CreateTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :trips do |t|

      t.belongs_to :driver
      t.string :status

      t.datetime :date

      t.text :route
      t.timestamps
    end
  end
end
