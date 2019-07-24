class EmployerShiftManagersController < ApplicationController
  before_action :set_employer_shift_manager, only: [:show, :edit, :update, :destroy]

  def index
    @employer_shift_managers = EmployerShiftManager.all
    render json: ManageUsers::ManageEmployerShiftManagersDatatable.new(view_context)
  end

  def show
  end

  def new
    @user = User.new
    @user.entity = EmployerShiftManager.new
  end

  def edit
  end

  def create
    user =  User.new(employer_shift_manager_params.merge(role: 7))
    user.save_with_notify
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "employer-shift-managers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def update
    employer_shift_manager_params['entity_attributes']['entity_id'] = @user.entity_id
    @user.update(employer_shift_manager_params)
    @errors = @user.errors.full_messages.to_sentence
    @datatable_name = "employer-shift-managers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to current_user.employer_shift_manager? ? user_profile_edit_path : provisioning_path(anchor: @datatable_name) }
    end
  end

  def destroy
    @employer_shift_manager.destroy
    respond_to do |format|
      format.html { redirect_to employer_shift_managers_url, notice: 'Employer shift manager was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_employer_shift_manager  
    @employer_shift_manager = EmployerShiftManager.find(params[:id])
    @user = @employer_shift_manager.user
  end

  def employer_shift_manager_params
    params.require(:user).permit!
  end
end
