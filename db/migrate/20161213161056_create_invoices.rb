class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.references :company, :polymorphic => true
      t.datetime :date
      t.datetime :start_date
      t.datetime :end_date
      t.integer :trips_count
      t.decimal :amount, precision: 12, scale: 2

      t.timestamps
    end
  end
end
