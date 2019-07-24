require 'services/google_service'

class EmployeesController < ApplicationController
  before_action :set_employee, only: [:edit, :update, :destroy, :invite]
  before_action :set_line_manager, only: [:new, :edit]
  before_action :is_guard_configuration_enabled, only: :guards
  before_action :set_email, only: [:create, :update]

  def index
    respond_to do |format|
      if current_user.admin? || current_user.employer?
        employee = Employee.includes(:user => { :entity => [:employee_company, :zone, :site]}).not_guard
        employee = employee.ransack(Searchables::EmployeeSearchable.new(params[:search_input]).send("by_#{params[:search_by]}")).result.joins(:user).order("f_name ASC, m_name ASC, l_name ASC") if params[:search_input].present? && params[:search_by].present?
        format.html
        format.json { render json: ManageUsers::ManageEmployeesDatatable.new(view_context, employee)}
      elsif current_user.line_manager?
        employee = Employee.includes(:user => { :entity => [:employee_company, :zone, :site]}).not_guard.accessible_by(current_ability, :read)
        employee = employee.ransack(Searchables::EmployeeSearchable.new(params[:search_input]).send("by_#{params[:search_by]}")).result.joins(:user).order("f_name ASC, m_name ASC, l_name ASC") if params[:search_input].present? && params[:search_by].present?
        format.html
        format.json { render json: ManageUsers::ManageEmployeesDatatable.new(view_context, employee)}
      else
        format.json { render json: 'Sorry, you have not permissions', status: '404' }
      end
    end
  end

  def new
    @employee = User.new
    @employee.entity = Employee.new
    @billing_zones = ZoneRate.uniq.pluck(:name)
  end

  def create
    user =  User.new(employee_params.except(:id, :role).merge(:role => 0))
    user.entity.employee_company_id = current_user.admin? ? employee_params[:entity_attributes][:employee_company_id] : current_user.entity&.employee_company_id
    user.save_with_notify
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = user.entity.is_guard ? 'guards' : 'employees'

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def edit
    @employee = @employee.user
    @billing_zones = ZoneRate.uniq.pluck(:name)
    # puts "---------------"
    # puts @billing_zones
    # @billing_zones = [['male': 'male'], ['female': 'female'], ['other': 'other']]
  end

  def update
    authorize! :update, @employee
    attr = employee_params
    attr['entity_attributes']['entity_id'] = @user.entity_id
    @user.update(attr)
    @errors = @user.errors.full_messages.to_sentence
    @datatable_name = @user.entity.is_guard ? 'guards' : 'employees'

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def destroy
    authorize! :destroy, @employee
    anchor = @employee.is_guard ? 'guards' : 'employees'
    @user.destroy
    respond_to do |format|
      format.html { redirect_to provisioning_path(anchor: anchor) }
      format.json { head :no_content }
    end
  end

  def invite
    UserNotifierMailer.user_create(@user).deliver_now!
    @user.update_invite_count
    @user.send_sms
    render json: true, status: 200
  end

  def guards
    respond_to do |format|
      if current_user.admin? || current_user.employer? || current_user.transport_desk_manager?
        employees = Employee.where(is_guard: true)
        format.json { render json: ManageUsers::ManageEmployeesDatatable.new(view_context, employees)}
      else
        format.json { render json: 'Sorry, you have not permissions', status: '404' }
      end
    end
  end

  def validate
    if params[:id].present?
      employee = Employee.find_by_prefix(params[:id])
      emp_params = employee_params
      emp_params['entity_attributes']['entity_id'] = employee.user.entity_id
      user = employee.user
      user.assign_attributes(emp_params)
    else
      user = User.new(employee_params.except(:id, :role).merge(:role => 0))
      user.entity.employee_company_id = current_user.admin? ? employee_params[:entity_attributes][:employee_company_id] : current_user.entity&.employee_company_id
    end
    user.valid?
    render json: user.errors.messages, status: 200
  end

  def get_geocode
    result = GoogleService.new.geocode(params[:home_address]).first
    json_output = result.present? && result[:geometry].present? ? result[:geometry][:location] : {}
    render json: json_output, status: 200
  end

  def get_nodal_geocode
    result = GoogleService.new.geocode(params[:nodal_address]).first
    json_output = result.present? && result[:geometry].present? ? result[:geometry][:location] : {}
    render json: json_output, status: 200
  end

  private

  def set_line_manager
    @line_managers = LineManager.includes(:user).all.map {|x| [x.full_name, x.id]}
    @is_guard = params[:is_guard].present? ? true : false
  end

  def set_employee
    @employee = Employee.find_by_prefix(params[:id])
    @user = @employee&.user
  end

  def employee_params
    if params['user']
      params.require(:user).permit!
    else
      params.require(:data).permit!
    end
  end

  def is_guard_configuration_enabled
    render json: 'Sorry, you have not permissions', status: '404' and return if ENV["ENALBE_GUARD_PROVISIONGING"] != "true"
  end

  def set_email
    return unless params[:user][:email].blank? && params[:user][:entity_attributes][:is_guard] == '1'
    params[:user][:email] = "guard-#{(Time.now.to_f * 1000).to_i}@moove.com"
  end
end
