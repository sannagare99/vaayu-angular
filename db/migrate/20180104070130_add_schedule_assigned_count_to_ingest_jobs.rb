class AddScheduleAssignedCountToIngestJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :ingest_jobs, :schedule_assigned_count, :integer, default: 0
  end
end
