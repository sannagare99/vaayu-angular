class CreateCompliances < ActiveRecord::Migration[5.0]
  def change
    create_table :compliances do |t|
      t.string :key
      t.integer :modal_type
      t.integer :compliance_type

      t.timestamps
    end
  end
end
