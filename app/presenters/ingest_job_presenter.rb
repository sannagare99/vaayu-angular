class IngestJobPresenter
  def initialize(ingest_job)
    @ingest_job = ingest_job
  end

  def as_json
    {
      data: {
        stats: stats,
        status: @ingest_job.status,
        error_data: error_data
      }
    }
  end

  def stats
    {
      processed_row_count: @ingest_job.processed_row_count,
      schedule_updated_count: @ingest_job.schedule_updated_count,
      employee_provisioned_count: @ingest_job.employee_provisioned_count,
      schedule_provisioned_count: @ingest_job.schedule_provisioned_count,
      schedule_assigned_count: @ingest_job.schedule_assigned_count,
      failed_row_count: @ingest_job.failed_row_count
    }
  end

  def error_data
    CSV.parse(Paperclip.io_adapters.for(@ingest_job.error_file).read, headers: true).map(&:to_hash) if @ingest_job.error_file.exists?
  end
end
