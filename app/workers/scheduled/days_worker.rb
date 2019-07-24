class Scheduled::DaysWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # Every day at 00:01
  recurrence { daily.hour_of_day(22).minute_of_hour(00) }

  def perform
    # generate_invoices
    if ENV["SEND_ANALYTICS_REPORT"] == "true"
      send_analytics_report
    end

    create_checklists

    #Create compliance notifications
    create_compliance_notifications
  end

  def send_analytics_report
    # @trips = Trip.all.where('scheduled_date >= ?', Time.new.in_time_zone('Chennai').beginning_of_day).order('id DESC')
    yesterday = (Time.now.in_time_zone('Chennai') - 1.day).beginning_of_day
    @trips = Trip.all.where('scheduled_date >= ?', yesterday).order('id DESC')
    trip_log_csv = Trip.trip_logs_csv({}, { trips: @trips, from_reports: true })
    employee_log_csv = Trip.employee_logs_csv({}, { trips: @trips, from_reports: true })
    AnalyticsMailer.analytics_mailer(trip_log_csv, employee_log_csv).deliver_now!
  end
  
  def generate_invoices
    # invoice_frequency one day
    EmployeeCompany.where(:invoice_frequency => 0).each do |company|
      GenerateInvoiceWorker.perform_async(company.id, 'employee_company')
    end

    BusinessAssociate.where(:invoice_frequency => 0).each do |company|
      GenerateInvoiceWorker.perform_async(company.id, 'business_associate')
    end
  end

  def create_checklists
    Driver.create_checklist
    Vehicle.create_checklist
  end

  def create_compliance_notifications
    Driver.create_notification
    Vehicle.create_notification
  end
end