class ReportsController < ApplicationController
  before_action :authorize_actions, except: [:show, :send_report, :download]
  before_action :can_download_report, only: [:send_report, :download]
  before_action :set_report_download_config

  def show
    authorize!(:show, :reports)
  end

  # # Reports about Active trips
  # def active
  #   respond_to do |format|
  #     format.html
  #     format.json { render json: Reports::ReportActiveTripsDatatable.new(view_context)}
  #   end
  # end

  # # Reports about Completed trips
  # def completed
  #   respond_to do |format|
  #     format.html
  #     format.json { render json: Reports::ReportCompletedTripsDatatable.new(view_context)}
  #   end
  # end

  # # Reports Capacity Utilization table
  # def utilization
  #   respond_to do |format|
  #     format.html
  #     format.json { render json: Reports::ReportUtilizationsDatatable.new(view_context)}
  #   end
  # end

  # # Reports Exceptions Summary table
  # def exceptions_summary
  #   respond_to do |format|
  #     format.html
  #     format.json { render json: Reports::ExceptionsSummary.new(view_context)}
  #   end
  # end

  # Reports about Operations summary
  def operations_summary
    respond_to do |format|
      format.html
      format.json { render json: Reports::ReportOperationsSummaryDatatable.new(view_context)}
    end
  end

  # Reports Capacity On Time Arrivals
  def ota_summary
    render json: Reports::ReportOtaSummariesDatatable.new(view_context)
  end

  # Reports Exceptions On Time Departures
  def otd_summary
    render json: Reports::ReportOtdSummariesDatatable.new(view_context)
  end

  # Reports about On No Show and Cancellation
  def no_show_and_cancellations
    respond_to do |format|
      format.html
      format.json { render json: Reports::ReportNoShowAndCancellationsDatatable.new(view_context)}
    end
  end

  # Reports about Panic Alarms
  def panic_alarms
    respond_to do |format|
      format.html
      format.json { render json: Reports::ReportPanicAlarmsDatatable.new(view_context)}
    end
  end

  def trip_logs
    render json: Reports::ReportTripLogsDatatable.new(view_context)
  end

  def employee_logs
    render json: Reports::ReportEmployeeLogsDatatable.new(view_context)
  end

  def vehicle_deployment
    render json: Reports::ReportVehicleDeploymentsDatatable.new(view_context)
  end

  def ota
    render json: Reports::ReportOtasDatatable.new(view_context)
  end

  def otd
    render json: Reports::ReportOtdsDatatable.new(view_context)
  end

  def employee_no_show
    render json: Reports::ReportEmployeeNoShowsDatatable.new(view_context)
  end

  def employee_satisfaction
    render json: Reports::ReportEmployeeSatisfactionsDatatable.new(view_context)
  end

  def employee_activity
    render json: Reports::ReportEmployeeActivitiesDatatable.new(view_context)
  end

  def driver_activity
    render json: Reports::ReportDriverActivitiesDatatable.new(view_context)
  end

  def drivers_trip_summary
    render json: Reports::ReportDriversTripSummariesDatatable.new(view_context)
  end

  def employee_wise_no_show
    render json: Reports::ReportEmployeeWiseNoShowsDatatable.new(view_context)
  end

  def shift_fleet_utilisation_summary
    render json: Reports::ReportShiftFleetUtilisationSummariesDatatable.new(view_context)
  end

  def shift_wise_no_show
    render json: Reports::ReportShiftWiseNoShowsDatatable.new(view_context)
  end

  def trip_wise_driver_exception
    render json: Reports::ReportTripWiseDriverExceptionsDatatable.new(view_context)
  end

  def vendor_trip_distribution
    render json: Reports::ReportVendorTripDistributionsDatatable.new(view_context)
  end

  def send_report
    ReportWorker.perform_async(params)
    render json: true, status: 200
  end

  def download
    filename = "#{params[:report_name]}-#{Date.today}.csv"
    report_obj = Object.const_get("Reports::Report#{params[:report_name].camelize}Datatable").new(view_context)
    send_data report_obj.csv, filename: filename
  end

  private

  def authorize_actions
    return if current_ability.can?(:view, :all_reports)
    authorize!(:view, params[:action].to_sym)
  end

  def can_download_report
    return if current_ability.can?(:view, :all_reports)
    authorize!(:view, params[:action].to_sym)
    action_name = ["trip_logs", "employee_logs", "no_show_and_cancellations", "panic_alarms"].include?(params[:report_name]) ? params[:report_name] : params[:report_name].singularize
    authorize!(:view, action_name.to_sym)
  end

  def set_report_download_config
    conf = Configurator.where(request_type: 'reports_download_button').first
    @can_perform_download = conf.present? ? ActiveModel::Type::Boolean.new.cast(conf.value) : false
  end
end
