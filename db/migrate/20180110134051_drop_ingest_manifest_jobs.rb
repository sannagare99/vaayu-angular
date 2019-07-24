class DropIngestManifestJobs < ActiveRecord::Migration[5.0]
  def change
    drop_table :ingest_manifest_jobs
  end
end
