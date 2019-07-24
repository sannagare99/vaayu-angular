class AnalyticsMailer < ApplicationMailer
  default template_path: 'mailers/analytics_mailer'

  def analytics_mailer(trip_logs_csv, employee_logs_csv)
    # @user = user
    # @password = generated_password
    attachments.inline['logo-dark.png'] = File.read('app/assets/images/logo-dark.png')
    attachments['trip_logs_csv.csv'] = trip_logs_csv
    attachments['employee_logs_csv.csv'] = employee_logs_csv
    mail(
        to: "harman@pnplabs.in, nitish@inloop.network, mustaq@inloop.network, vishu@inloop.network, rahul@inloop.network, varun@inloop.network, dinu@inloop.network, yashanshu@inloop.network, swati@inloop.network, vishuagarwal10@gmail.com",
        subject: "#{ENV['SITE_NAME']} Analytics Report"
    )
  end

end
