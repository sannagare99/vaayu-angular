class EmployersController < ApplicationController

  def index
    respond_to do |format|
      if current_user.admin?
        format.html
        format.json { render json: ManageUsers::ManageEmployersDatatable.new(view_context)}
      elsif (employee_companies = current_user.entity&.logistics_company.employee_companies)
        format.html
        format.json { render json: ManageUsers::ManageEmployersDatatable.new(view_context)}
      else
        render :json => { :errors => 'You have not permissions for create company' }
      end
    end
  end

  def new
    @user = User.new
    @user.entity = Employer.new
  end

  def edit
    @user = Employer.find(params[:id]).user
  end

  def create
    user =  User.new(employer_params.except(:id, :role).merge(:role => 1))
    user.save_with_notify
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "employers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def update
    user = Employer.find_by_prefix(params[:id]).user
    employer_params['entity_attributes']['entity_id'] = user.entity_id
    @datatable_name = "employers"
    redirect_url = current_user.employer? ? user_profile_edit_path : provisioning_path(anchor: @datatable_name)
    user.update(employer_params)

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to redirect_url }
    end
  end

  def destroy
    user = Employer.find_by_prefix(params[:id]).user
    user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    def set_employer
      @employer = Employer.find_by_prefix(params[:id])
    end

    def employer_params
      params.require(:user).permit!
    end
end
