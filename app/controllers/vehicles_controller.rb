class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:edit, :update, :destroy, :vehicle_broke_down, :vehicle_ok]
  before_action :only_admin_and_operator, only: [:create, :update]

  def index
    # @vehicles = params[:search_input].present? && params[:search_by].present? ? Vehicle.ransack(Searchables::VehicleSearchable.new(params[:search_input]).send("by_#{params[:search_by]}")).result.order("plate_number ASC") : Vehicle.all
    respond_to do |format|
      format.html
      format.json { render json: VehiclesDatatable.new(view_context) }
    end
  end

  def new
    @vehicle = Vehicle.new
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)
    @vehicle.save
    @errors = @vehicle.errors.full_messages.to_sentence
    @datatable_name = "vehicles"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def edit

  end

  def update
    @vehicle.update(vehicle_params)
    @errors = @vehicle.errors.full_messages.to_sentence
    @datatable_name = "vehicles"

    respond_to do |format|
      format.js { render file: "shared/create" }
      format.html { redirect_to provisioning_path(anchor: @datatable_name) }
    end
  end

  def destroy
    if current_user.admin? || current_user.operator?
      @vehicle.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  def vehicle_broke_down
    # Create a new trip request for car brokw down
    if @vehicle.driver.present?

      @driver_request = @vehicle.driver.driver_requests.new(
          reason: '',
          request_type: 'car_broke_down',
          driver: @driver,
          request_date: Time.now
      )
      @driver_request.vehicle = @vehicle

      @driver_request.save

      #Approve the car broke down request by the driver
      @driver_request.approve!
    else
      @vehicle.vehicle_broke_down!
    end
  end

  def vehicle_ok
    if params['request_id'].present?
      driver_request = DriverRequest.find(params['request_id'])
      if driver_request.present?
        driver_request.cancel_approved!
      end
    else
      @vehicle.vehicle_ok!
    end
  end

  def checklist
    @checklist = Checklist.find(params[:id])
    @vehicle = @checklist.vehicle
    @checklist_progress = ((@checklist.checklist_items.checked.size.to_f / @checklist.checklist_items.size) * 100).round
    @total_fields = @checklist.checklist_items.size
  end

  def update_checklist
    checklist = Checklist.find params[:id]
    checklist.update_checklist_items(checklist_params)
    render json: true, status: 200
  end
  
  def vehicle_break_down_approve_decline
    if params['request_id'].present?
      driver_request = DriverRequest.find(params['request_id'])
      if params['approve'] == '1'
        driver_request.approve!
      else
        driver_request.decline!
      end
    end
  end

  private
  def checklist_params
    params.require(:checklist_items).permit!
  end
    
  def set_vehicle
    @vehicle = Vehicle.find_by_prefix(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(
        :driver_id, :business_associate_id, :name, :make, :plate_number, :model, :colour, :photo,
        :driver_name, :rc_book_no, :registration_date, :insurance_date, :fuel_type, :permit_type,
        :permit_validity_date, :puc_validity_date, :fc_validity_date, :ac, :make_year, :induction_date,
        :odometer, :spare_type, :first_aid_kit, :tyre_condition, :device_id,
        :seats, :fuel_level, :plate_condition
    )
  end

  def only_admin_and_operator
    return if current_user.admin? || current_user.operator?
    flash[:error] = 'You have not permissions for update vehicle'
    redirect_to provisioning_path(anchor: 'vehicles')
  end
end
