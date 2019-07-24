class ShiftTimesController < ApplicationController

  before_action :shift_manager_klass#, only: [:schedule_time, :timings]
  before_action :shift_time_klass, only: :update_time
  before_action :can_create_or_update_shifts, only: :update_time

  def schedule_time
    @schedule = []
    @new_shift_times = []
    14.times { @new_shift_times << OperatorShiftManagerTime.new }
    @sites = @shift_manager.sites
  end

  def timings
    employee = Employee.find(params[:id])
    range_from = Date.parse(params[:range_from])
    range_to = Date.parse(params[:range_to]) + 1.day
    timings = @shift_manager.shift_times.where(schedule_date: range_from..range_to).group_by { |et| et.schedule_date.strftime("%U") }
    timings = timings.map { |week_no, et| { week_no => et.as_json(only: [:id, :date, :site_id, :shift_type, :schedule_date])} }
    render json: timings, status: 200
  end

  def update_time
    return_data = {}
    return_data[:status] = 400 and raise RuntimeError unless params[:employee].present?
    return_data[:status] = 400 and raise RuntimeError if params[:employee][:check_in_attributes].blank? || params[:employee][:check_out_attributes].blank?

    ShiftTime.create_or_update(@klass, shift_time_params, @shift_manager)
    flash[:notice] = 'Employee Trips are successfully updated'
    return_data[:message] = "Employee Trips are successfully updated"
    return_data[:status] = 200
  rescue RuntimeError
    response[:message] = "Invalid parameters"
  ensure
    render json: return_data, status: return_data[:status]
  end

  private

  def shift_time_params
    params.require(:employee).permit!
  end

  def shift_manager_klass
    @sm_type = params[:sm_type]
    klass = @sm_type.classify.constantize
    @shift_manager = klass.find(params[:id])
  end

  def shift_time_klass
    @klass = @sm_type == "operator_shift_manager" ? OperatorShiftManagerTime : EmployerShiftManagerTime
  end

  def can_create_or_update_shifts
    render json: {status: 401, message: "User not authorized to perform this action."}, status: 401 and return unless can? :manager, @shift_manager
  end

  # def shift_manager_type_filter
  #   redirect_to root_path if params[:sm_type].nil? || params[:sm_type].classify.constantize rescue true
  # end
end
