class Scheduled::MonthsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  # Every first day of the month
  recurrence { monthly.day_of_month(14).hour_of_day(16).minute_of_hour(40) }

  def perform
    # generate_invoices
    generate_invoices
  end
  
  def generate_invoices
    # invoice_frequency one day
    Site.all.each do |site|
      site.generate_invoice
    end
  end
end