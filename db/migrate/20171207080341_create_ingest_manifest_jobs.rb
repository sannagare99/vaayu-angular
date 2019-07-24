class CreateIngestManifestJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :ingest_manifest_jobs do |t|
      t.string :status

      t.integer :failed_row_count, default: 0
      t.integer :processed_row_count, default: 0
      t.integer :schedule_updated_count, default: 0
      t.integer :employee_provisioned_count, default: 0
      t.integer :schedule_provisioned_count, default: 0

      t.references :user

      t.attachment :file
      t.attachment :error_file

      t.timestamps
    end
  end
end
