class CreateIngestJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :ingest_jobs do |t|
      t.date :start_date
      t.attachment :file
      t.string :status

      t.references :user

      t.timestamps
    end
  end
end
