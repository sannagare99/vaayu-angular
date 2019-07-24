require 'digest'

class IngestJobController < ApplicationController
  def create
    sha1 = get_file_digest(ingest_job_params[:file].tempfile)
    if ingest_job = IngestJob.find_pending_job_by_digest(sha1)
      render json: {id: ingest_job.id}
    else
      ingest_job = IngestJob.new(ingest_job_params)
      ingest_job.user = current_user
      ingest_job.file_digest = sha1
      if ingest_job.save && ingest_job.process_file
        render json: {id: ingest_job.id}
      else
        render json: ingest_job.errors.json_messages, status: :unprocessable_entity
      end
    end
  end

  def show
    ingest_job = IngestJob.find(params[:id])
    render json: ::IngestJobPresenter.new(ingest_job)
  end

  private
  def ingest_job_params
    params.require(:ingest_job).permit!
  end

  def get_file_digest(file)
    Digest::SHA1.file(file).hexdigest
  end
end
