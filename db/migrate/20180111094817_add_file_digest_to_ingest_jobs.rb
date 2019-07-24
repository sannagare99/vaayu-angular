class AddFileDigestToIngestJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :ingest_jobs, :file_digest, :string
  end
end
