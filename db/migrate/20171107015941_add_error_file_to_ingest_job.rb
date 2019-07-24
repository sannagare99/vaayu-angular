class AddErrorFileToIngestJob < ActiveRecord::Migration[5.0]
  def change
    add_attachment :ingest_jobs, :error_file
  end
end
