class IngestManifestJobPresenter
  def initialize(ingest_manifest_job)
    @ingest_manifest_job = ingest_manifest_job
  end

  def as_json
    {
      data: {
        status: @ingest_manifest_job.status,
        stats: stats,
        error_data: error_data
      }
    }
  end

  def stats
    {
      processed_row_count: @ingest_manifest_job.processed_row_count,
      schedule_updated_count: @ingest_manifest_job.schedule_updated_count,
      employee_provisioned_count: @ingest_manifest_job.employee_provisioned_count,
      schedule_provisioned_count: @ingest_manifest_job.schedule_provisioned_count,
      failed_row_count: @ingest_manifest_job.failed_row_count
    }
  end

  def error_data
    CSV.parse(Paperclip.io_adapters.for(@ingest_manifest_job.error_file).read, headers: true).map(&:to_hash) if @ingest_manifest_job.error_file.exists?
  end
end
