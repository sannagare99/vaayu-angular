class CreateChecklistItems < ActiveRecord::Migration[5.0]
  def change
    create_table :checklist_items do |t|
      t.integer :checklist_id
      t.string :key
      t.boolean :value
      t.integer :compliance_type

      t.timestamps
    end
  end
end
