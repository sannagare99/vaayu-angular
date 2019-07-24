class AddIngestTypeIngestJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :ingest_jobs, :ingest_type, :string
  end
end
