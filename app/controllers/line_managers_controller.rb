class LineManagersController < ApplicationController

  before_action :load_line_manager, only: [:update, :destroy, :invite, :edit_list, :update_employee_list]
  def index
    respond_to do |format|
      if current_user.admin?
        # @employer = Employer.all.order('id DESC')
        format.html
        format.json { render json: ManageUsers::ManageLineManagersDatatable.new(view_context)}
      elsif current_user.employer?
        # @employer = Employer.where(:employee_company => employee_companies).order('id DESC')
        format.html
        format.json { render json: ManageUsers::ManageLineManagersDatatable.new(view_context)}
      else
        render :json => { :errors => 'You have not permissions for create company' }
      end
    end
  end

  def new
    @line_manager = User.new
    @line_manager.entity = Employee.new
  end

  def edit
    line_manager = LineManager.find_by_prefix(params[:id])
    @line_manager = line_manager.user
  end

  def create
    user =  User.new(line_manager_params.except(:id, :role).merge(:role => 6))
    user.save_with_notify
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "line-managers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def update
    user = LineManager.find_by_prefix(params[:id]).user
    line_manager_params['entity_attributes']['entity_id'] = user.entity_id
    redirect_url = current_user.line_manager? ? user_profile_edit_path : provisioning_path(anchor: 'line-managers')
    user.update(line_manager_params)
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "line-managers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to redirect_url }
    end
  end

  def destroy
    user = LineManager.find_by_prefix(params[:id]).user
    user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def invite
    UserNotifierMailer.user_create(@user, @user.generate_reset_password_token).deliver_now!
    @user.update_invite_count
    render json: true, status: 200
  end

  def edit_list
    @employees = Employee.includes(:user)
  end

  def update_employee_list
    emp_ids = employee_param[:employee_attributes].values.map { |x| x[:id] if x[:line_manager_id] == params[:id] }.compact
    @line_manager.employees = Employee.find(emp_ids)
    render json: true, status: 200
  end

  private

  def line_manager_params
    params.require(:user).permit!
  end

  def employee_param
    params.require(:line_manager).permit(employee_attributes: [:id, :line_manager_id])
  end

  def load_line_manager
    @line_manager = LineManager.find_by_prefix(params[:id])
    @user = @line_manager.user
  end
end
