class OperatorsController < ApplicationController

  def index
    respond_to do |format|
      format.html
      format.json { render json: ManageUsers::ManageOperatorsDatatable.new(view_context)}
    end
  end

  def new
    @operator = User.new
    @operator.entity = Operator.new
  end

  def edit
    operator = Operator.find(params[:id])
    @operator = operator.user
  end

  def create
    user =  User.new(user_params.except(:id, :role).merge(:role => 2))
    user.save_with_notify
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "logistic-companies-users"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def update
    user = Operator.find_by_prefix(params[:id]).user
    attr = user_params
    attr['entity_attributes']['entity_id'] = user.entity_id
    redirect_url = current_user.operator? ? user_profile_edit_path : provisioning_path(anchor: 'logistic-companies-users')
    @datatable_name = "logistic-companies-users"

    respond_to do |format|
      if user.update(attr)
        @errors = user.errors.full_messages.to_sentence
        format.html do
          flash[:notice] = 'Congratulations! Your profile was successfully updated.'
          redirect_to redirect_url
        end
        format.json { render json: ManageUsers::ManageOperatorDatatable.new(user), status: :ok}
        format.js { render file: "shared/create" }
      else
        @errors = user.errors.full_messages.to_sentence
        format.html do
          flash[:error] = user.errors.full_messages.to_sentence
          redirect_to redirect_url
        end
        format.json { render json: user.errors.json_messages, status: :ok }
        format.js { render file: "shared/create" }
      end
    end
  end

  def destroy
    user = Operator.find_by_prefix(params[:id]).user
    user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    def user_params
      if params['user']
        params['user']['entity_attributes']['entity_id'] = params['user']['entity_attributes']['id']
        params.require(:user).permit(
            :id, :f_name, :m_name, :l_name, :email, :role, :phone, :avatar,
            :entity_attributes => [
                :id, :entity_id, :logistics_company_id, :legal_name, :pan, :tan, :business_type, :service_tax_no, :hq_address
            ]
        )
      else
        entity_id = params['id']
        params['operator'] = params['data'][entity_id]
        params['operator']['entity_attributes']['entity_id'] = entity_id

        params.require(:operator).permit(
            :id, :f_name, :m_name, :l_name, :email, :role, :phone, :avatar,
            :entity_attributes => [
                :id, :entity_id, :logistics_company_id, :legal_name, :pan, :tan, :business_type, :service_tax_no, :hq_address
            ]
        )
      end
    end
end
