class TransportDeskManagersController < ApplicationController

  def index
    respond_to do |format|
      if current_user.admin?
        # @employer = Employer.all.order('id DESC')
        format.html
        format.json { render json: ManageUsers::ManageTransportDeskManagersDatatable.new(view_context)}
      elsif current_user.employer?
        # @employer = Employer.where(:employee_company => employee_companies).order('id DESC')
        format.html
        format.json { render json: ManageUsers::ManageTransportDeskManagersDatatable.new(view_context)}
      else
        render :json => { :errors => 'You have not permissions for create company' }
      end
    end
  end

  def new
    @user = User.new
    @user.entity = TransportDeskManager.new
  end

  def edit
    @user = TransportDeskManager.find_by_prefix(params[:id]).user
  end

  def create
    user =  User.new(transport_desk_manager_params.except(:id, :role).merge(:role => 5))
    user.save_with_notify
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "transport-desk-managers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def update
    user = TransportDeskManager.find_by_prefix(params[:id]).user
    transport_desk_manager_params['entity_attributes']['entity_id'] = user.entity_id
    user.update(transport_desk_manager_params)
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "transport-desk-managers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to current_user.transport_desk_manager? ? user_profile_edit_path : provisioning_path(anchor: @datatable_name) }
    end
  end

  def destroy
    user = TransportDeskManager.find_by_prefix(params[:id]).user
    user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def transport_desk_manager_params
    params.require(:user).permit!
  end
end
