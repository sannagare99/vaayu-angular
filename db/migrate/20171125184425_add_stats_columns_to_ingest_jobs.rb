class AddStatsColumnsToIngestJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :ingest_jobs, :failed_row_count, :integer, default: 0
    add_column :ingest_jobs, :processed_row_count, :integer, default: 0
    add_column :ingest_jobs, :schedule_updated_count, :integer, default: 0
    add_column :ingest_jobs, :employee_provisioned_count, :integer, default: 0
    add_column :ingest_jobs, :schedule_provisioned_count, :integer, default: 0
  end
end
