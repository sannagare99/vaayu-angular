class ReportsMailer < ApplicationMailer
  default template_path: 'mailers/reports_mailer'

  def send_report(email, report_obj, report_name, date_range)
    attachments["#{report_name}.csv"] = report_obj.csv
    @email = email
    mail(to: email, subject: "Report #{report_name.humanize} for #{date_range}")
  end
end
