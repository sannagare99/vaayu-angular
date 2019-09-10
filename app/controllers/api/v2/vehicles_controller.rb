class API::V2::VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, unless: -> { ['devise_token_auth', 'overrides' ].include?(params[:controller].split('/')[0])}
  before_action :validate_plate_number, only: [:create]
  before_action :check_insurance_date, only: [:create]
  before_action :check_puc_validity_date, only: [:create] 
  before_action :check_permit_validity_date, :check_authorization_certificate_validity_date, :check_fitness_validity_date, :check_road_tax_validity_date, only: [:create]
  respond_to :json
  # GET /api/v2/vehicles
  # GET /api/v2/vehicles.json
  def index
    @vehicles = Vehicle.all
    render json: { status: "True" , message: "Loaded vehicles", data: { Vehicle: @vehicles }, errors: {} }, status: :ok
  end

  # GET /api/v2/vehicles/1
  # GET /api/v2/vehicles/1.json
  def show
    if @vehicle.present?
      render json: {status: "True" , message: "Loaded vehicles", data: { vehicle: @vehicle }, errors: {} },status: :ok
    else
      render json: {status: "False" , message: "No vehicle found", data: {}, errors: {} }, status: :not_found
    end
  end

  # GET /api/v2/vehicles/new
  def new
    @vehicle = Vehicle.new
  end

  # GET /api/v2/vehicles/1/edit
  def edit
  end

  # POST /api/v2/vehicles
  # POST /api/v2/vehicles.json
  def create
    save_draft(params)
  end

  # PATCH/PUT /api/v2/vehicles/1
  # PATCH/PUT /api/v2/vehicles/1.json
  def update
   if @vehicle.update(vehicle_params)
      render json: {status: "True" , message: "UPDATE SUCCESS", data: { vehicle: @vehicle } , errors: {} },status: :ok
    else
      render json: {status: "False" , message: "UPDATE FAIL", data: {}, errors: @vehicle.errors.split(",") },status: :unprocessable_entity
    end
  end

  # DELETE /api/v2/vehicles/1
  # DELETE /api/v2/vehicles/1.json
  def destroy
    if @vehicle.destroy
      render json: {status: "True" , message: "Deleted vehicle", data: { vehicle: @vehicle }},status: :ok
    else
      render json: {status: "False" , message: "DELETE FAIL", data: {}, errors: @vehicle.errors },status: :unprocessable_entity
    end
  end

  def find_category_seat_by_vehicle
    vehicle = VehicleModel.find_by_make_model(params[:make_model]) if params[:make_model].present?
    vehicle_data = { capacity: vehicle.capacity.to_i , vehicle_category: vehicle.vehicle_category.category_name } if vehicle.present? && vehicle.vehicle_category.present?
    success =  {status: "True" , message: "Get vehicle data ", status: :ok, data: vehicle_data , errors: {} }
    not_found = {status: "False" , message: "Not found vehicle data", status: :not_found, errors: {} }
    render json: vehicle_data.present? ? success : not_found
  end


  def get_vehicle_model_data
    vehicle_models = VehicleModel.all
    result = []
    if vehicle_models.present?
      vehicle_models.each do |vehicle_model|
      @vehicle_data = { make_model: vehicle_model.make_model, capacity: vehicle_model.capacity.to_i , vehicle_category: vehicle_model.vehicle_category.category_name }
        result << @vehicle_data
      end
      success =  {status: "True" , message: "Listing of VehicleModel", status: :ok, data: result , errors: {} }
      render json: success
    else
      not_found = {status: "False" , message: "Not found VehicleModel data", status: :not_found, errors: {} }
      render json: not_found
    end
  end

  def validate_plate_number
    if params[:plate_number].present?
      result = Vehicle.pluck(:plate_number).include? params[:plate_number]
      render json: {status: "True" , message: "Vehicle registration number should not be duplicate", data:{ plate_number: params[:plate_number] }, errors: {} }, status: :not_found if result
      render json: { status: "False" , message: "Plate number is unique", data: { plate_number: params[:plate_number] } , errors: {} }, status: :ok if result == false
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
      render json: {status: :not_found} unless @vehicle
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vehicle_params
      # params.permit(:business_associate_id, :plate_number, :model,:seats,:ac,:fuel_type,:colour,:registration_date, :fitness_doc_url, :insurance_date, :authorization_certificate_validity_date, :business_area_id, :make_year, :puc_validity_date, :fitness_validity_date, :permit_validity_date, :road_tax_validity_date, :ac,:fuel_type, :driver_id, :last_service_date, :last_service_km, :km_at_induction, :permit_type, :authorization_certificate_validity_date, :date_of_registration, :status, :device_id, :gps_provider_id, :insurance_doc_url, :rc_book_doc_url, :puc_doc_url, :commercial_permit_doc_url, :road_tax_doc_url, :vehicle_picture_url, :authorization_certificate_doc_url, :site_id, :created_by, :updated_by )
      params.permit(:business_associate_id, :plate_number, :model,:category,:seats,:ac, :colour,:puc_validity_date,:insurance_date,:permit_validity_date,:road_tax_validity_date,:authorization_certificate_validity_date,:fitness_validity_date, :fuel_type, :induction_status, :registration_steps, :insurance_doc, :insurance_doc_url, :rc_book_doc, :rc_book_doc_url, :puc_doc_url, :puc_doc, :commercial_permit_doc_url, :commercial_permit_doc, :road_tax_doc_url, :road_tax_doc)
    end

    def save_draft(params)
      if params[:registration_steps] == "Step_1"
        @vehicle = Vehicle.new(vehicle_params)
        @vehicle.make_year = @vehicle.make_year.present? ? @vehicle.make_year : 2015
        @vehicle.registration_steps = params[:registration_steps] if params[:registration_steps].present?
        @vehicle.induction_status = "Draft"
        if @vehicle.save
            render json: { status: "True" , message: "Success First step", data: { vehicle_id: @vehicle.id }, errors: {} }, status: :ok
          else
            render json: {status: "False" , message: "Fail First step", data: {}, errors: {},status: :unprocessable_entity }
          end
       elsif params[:registration_steps] == "Step_2"
          @vehicle = Vehicle.find(params[:vehicle_id])
          if @vehicle.update(vehicle_params)
              render json: {status: "True" , message: "Success second step", data: { vehicle_id:  @vehicle.id }, errors: {} }, status: :ok if @vehicle.id.present?
              else
                render json: {status: "False" , message: "Fail Final step", data: {}, errors: @vehicle.errors.split(",") },status: :unprocessable_entity if @vehicle.id.blank?
            end
        elsif params[:registration_steps] == "Step_3"
          @vehicle = Vehicle.find(params[:vehicle_id])
          if params[:insurance_date].blank? or params[:puc_validity_date].blank? or params[:authorization_certificate_validity_date].blank? or  params[:fitness_validity_date].blank? or params[:road_tax_validity_date].blank? or params[:permit_validity_date].blank?
              render json: {status: "False" , message: "Please Upload all docs", data: {}, errors: {},status: :unprocessable_entity }
          else
            if @vehicle.update(vehicle_params)
              upload_insurance_doc(@vehicle) if @vehicle.present?
              upload_rc_book_doc(@vehicle) if @vehicle.present?
              upload_puc_doc(@vehicle) if @vehicle.present?
              upload_commercial_permit_doc(@vehicle) if @vehicle.present?
              upload_road_tax_doc(@vehicle) if @vehicle.present?
              @vehicle.update(induction_status: "Registered") if @vehicle.present?
              render json: {status: "True" , message: "Success Final step", data:{vehicle_id: @vehicle.id } , errors: {} }, status: :ok if @vehicle.id.present?
        else
          render json: {status: "False" , message: "Fail Final step", data: {}, errors: @vehicle.errors.split(",") },status: :unprocessable_entity if @vehicle.id.blank?
        end
      end
      else
        render json: { status: "False" , message: "You have not assign registration steps", data: {}, errors: {} },status: :unprocessable_entity 
      end
    end

   def upload_insurance_doc(vehicle)
    if vehicle.insurance_doc.url.present?
      vehicle.update!(insurance_doc_url: vehicle.insurance_doc.url.gsub("//",''))
      logger.info "Insurance_doc done"
    end 
  end 

  def upload_rc_book_doc(vehicle)
    if vehicle.rc_book_doc.url.present?
      vehicle.update(rc_book_doc_url: vehicle.rc_book_doc.url.gsub("//",''))
      logger.info "rc_book done"
    end 
  end 

  def upload_puc_doc(vehicle)
    if vehicle.puc_doc.url.present?
      vehicle.update(puc_doc_url: vehicle.puc_doc.url.gsub("//",''))
      logger.info "puc_doc done"
    end 
  end 

  def upload_commercial_permit_doc(vehicle)
    if vehicle.commercial_permit_doc.url.present?
      vehicle.update(commercial_permit_doc_url: vehicle.commercial_permit_doc.url.gsub("//",''))
      logger.info "commercial_permi done"
    end 
  end 

  def upload_road_tax_doc(vehicle)
    if vehicle.road_tax_doc.url.present?
      vehicle.update(road_tax_doc_url: vehicle.road_tax_doc.url.gsub("//",''))
      logger.info "road_tax done"
    end 
  end 

  def check_insurance_date
    if params[:registration_steps] == "Step_2"
      if params[:insurance_date].present? && params[:insurance_date].to_date < Date.today 
        render json: {status: "False" , message: "Your insurance date has expired", data: {}, errors: "Record not updated",status: :unprocessable_entity }
      end
    end
  end

  def check_puc_validity_date
    if params[:registration_steps] == "Step_2"
      if params[:puc_validity_date].present? && params[:puc_validity_date].to_date < Date.today 
        render json: {status: "False" , message: "Your puc validity date has expired", data: {}, errors: "Record not updated",status: :unprocessable_entity }
      end
    end
  end

  def check_permit_validity_date
    if params[:registration_steps] == "Step_2"
      if params[:permit_validity_date].present? && params[:permit_validity_date].to_date < Date.today 
        render json: {status: "False" , message: "Your permit validity date has expired", data: {}, errors: "Record not updated",status: :unprocessable_entity }
      end
    end
  end

  def check_authorization_certificate_validity_date
    if params[:registration_steps] == "Step_2"
      if params[:authorization_certificate_validity_date].present? && params[:authorization_certificate_validity_date].to_date < Date.today 
        render json: {status: "False" , message: "Your authorization certificate validity date has expired", data: {}, errors: "Record not updated",status: :unprocessable_entity }
      end
    end
  end

  def check_fitness_validity_date
    if params[:registration_steps] == "Step_2"
      if params[:fitness_validity_date].present? && params[:fitness_validity_date].to_date < Date.today 
        render json: {status: "False" , message: "Your fitness validity date has expired", data: {}, errors: "Record not updated",status: :unprocessable_entity }
      end
    end
  end

  def check_road_tax_validity_date
    if params[:registration_steps] == "Step_2"
      if params[:road_tax_validity_date].present? && params[:road_tax_validity_date].to_date < Date.today 
        render json: {status: "False" , message: "Your road tax validity date has expired", data: {}, errors: "Record not updated",status: :unprocessable_entity }
      end
    end
  end
end


