class DriversController < ApplicationController
  before_action :set_driver, only: [:edit, :update, :destroy, :invite]
  before_action :set_email, only: [:create, :update]

  def index
    # drivers = params[:search_input].present? && params[:search_by].present? ? Driver.ransack(Searchables::DriverSearchable.new(params[:search_input]).send("by_#{params[:search_by]}")).result.joins(:user).order("f_name ASC, m_name ASC, l_name ASC") : Driver.all

    respond_to do |format|
      format.html
      format.json { render json: ManageUsers::ManageDriversDatatable.new(view_context)}
    end
  end

  def new
    @driver = User.new
    @driver.entity = Driver.new
  end

  def create
    user =  User.new(driver_params.except(:id, :role).merge(:role => 3))
    user.entity.logistics_company_id = current_user.admin? ? driver_params[:entity_attributes][:logistics_company_id] : current_user.entity&.logistics_company_id
    user.save_with_notify
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "drivers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def edit
    @driver = @driver.user
  end

  def update
    user = @driver.user
    attr = driver_params
    attr['entity_attributes']['entity_id'] = user.entity_id
    if @driver.licence_number != attr['entity_attributes']['licence_number']
      attr["password"] = attr['entity_attributes']["licence_number"].last(6)
    end
    user.update(attr)
    @errors = user.errors.full_messages.to_sentence
    @datatable_name = "drivers"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def destroy
    user = @driver.user
    user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def get_driver_requests
    respond_to do |format|
      format.html
      format.json { render json: DriverRequestsDatatable.new(view_context)}
    end    
  end

  def update_driver_requests
    result = {json: {}, status: :ok}
    begin
      driver_requests = DriverRequest.find(params['ids'])
      if params['type'] == 'approve'
        driver_requests.each do |request|
          if request.cancel?
            request.cancel_approved!
          elsif request.pending?
            request.approve!
          end
        end
      else
        driver_requests.each do |request| 
          if request.cancel?
            request.cancel_declined!
          elsif request.pending?
            request.decline!
          end
        end
      end
    rescue
      result = {json: 'Something wrong', status: '400'}
    end
    respond_to do |format|
      format.json {render result}
    end
  end

  def invite
    @driver.user.send_sms
    @driver.user.update_invite_count
    render json: true, status: 200
  end

  def stop_on_leave
    driver_request = DriverRequest.find(params['request_id'])
    if driver_request.present?
      driver_request.cancel_approved!
    end
  end    

  def validate
    driver_params['email'] = "driver-#{(Time.now.to_f * 1000).to_i}@moove.com" if driver_params['email'].blank?
    if params[:id].present?
      driver = Driver.find_by_prefix(params[:id])
      driver_param = driver_params
      driver_param['entity_attributes']['entity_id'] = driver.user.entity_id
      user = driver.user
      user.assign_attributes(driver_param)
    else
      user =  User.new(driver_params.except(:id, :role).merge(:role => 3))
      user.entity.logistics_company_id = current_user.admin? ? driver_params[:entity_attributes][:logistics_company_id] : current_user.entity&.logistics_company_id
    end
    user.valid?
    render json: user.errors.messages.except(:username), status: 200
  end

  def checklist
    @checklist = Checklist.find(params[:id])
    @driver = @checklist.driver
    @checklist_progress = ((@checklist.checklist_items.checked.size.to_f / @checklist.checklist_items.size) * 100).round
    @total_fields = @checklist.checklist_items.size
  end

  def update_checklist
    checklist = Checklist.find params[:id]
    checklist.update_checklist_items(checklist_params)
    render json: true, status: 200
  end

  private

  def set_driver
    @driver = Driver.find_by_prefix(params[:id])
  end

  def driver_params
    if params['user']
      params.require(:user).permit!
    else
      params.require(:data).permit!
    end
  end

  def checklist_params
    params.require(:checklist_items).permit!
  end

  def set_email
    return unless params[:user][:email].blank?
    params[:user][:email] = "driver-#{(Time.now.to_f * 1000).to_i}@moove.com"
  end
end
