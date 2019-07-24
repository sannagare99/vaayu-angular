class IngestMailer < ApplicationMailer
  default template_path: 'mailers/ingest_mailer'

  def notify(ingest_job)
    @ingest_job = ingest_job
    attachments.inline['errors.csv'] = Paperclip.io_adapters.for(ingest_job.error_file).read if ingest_job.error_file.exists?
    mail(
      to: ingest_job.user.email,
      subject: "#{ingest_job.ingest_type.titleize} #{ingest_job.completed? ? 'Successful' : 'Failed'}"
    )
  end
end
