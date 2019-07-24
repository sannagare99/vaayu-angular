class OperatorShiftManagersController < ApplicationController
  before_action :set_operator_shift_manager, only: [:show, :edit, :update, :destroy]

  def index
    @operator_shift_managers = OperatorShiftManager.all
    render json: ManageUsers::ManageOperatorShiftManagersDatatable.new(view_context)
  end

  def show
  end

  def new
    @user = User.new
    @user.entity = OperatorShiftManager.new
  end

  def edit
  end

  def create
    user =  User.new(operator_shift_manager_params.merge(role: 8))
    user.save_with_notify
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "operator-shift-managers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def update
    operator_shift_manager_params['entity_attributes']['entity_id'] = @user.entity_id
    @user.update(operator_shift_manager_params)
    @errors = @user.errors.full_messages.to_sentence
    @datatable_name = "operator-shift-managers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to current_user.operator_shift_manager? ? user_profile_edit_path : provisioning_path(anchor: @datatable_name) }
    end
  end

  def destroy
    @operator_shift_manager.destroy
    respond_to do |format|
      format.html { redirect_to operator_shift_managers_url, notice: 'Operator shift manager was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_operator_shift_manager
    @operator_shift_manager = OperatorShiftManager.find(params[:id])
    @user = @operator_shift_manager.user
  end

  def operator_shift_manager_params
    params.require(:user).permit!
  end
end
