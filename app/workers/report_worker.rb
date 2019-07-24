class ReportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: 5

  def perform(params)
    params.symbolize_keys!
    view_context = OpenStruct.new(params: ActionController::Parameters.new(params))
    report_obj = Object.const_get("Reports::Report#{params[:report_name].camelize}Datatable").new(view_context)
    start_date = params[:startDate] == '' ? Time.new(2009, 01, 01).to_date : Time.parse(params[:startDate] + " IST")
    end_date = params[:endDate] == '' ? Time.current().to_date : Time.parse(params[:endDate] + " IST")
    date_range = start_date.to_date == end_date.to_date ? "#{start_date.strftime('%d-%m-%Y')} #{start_date.strftime('%H:%M')} to #{end_date.strftime('%H:%M')}" : "#{start_date.strftime('%d-%m-%Y')} to #{end_date.strftime('%d-%m-%Y')}"

    params[:emails].split(",").select { |x| x.strip =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }.each do |email|
      ReportsMailer.send_report(email, report_obj, params[:report_name], date_range).deliver!
    end
  end
end
