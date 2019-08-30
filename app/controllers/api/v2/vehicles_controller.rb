class API::V2::VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy]
  # GET /api/v2/vehicles
  # GET /api/v2/vehicles.json
  def index
    @vehicles = Vehicle.all
    render json: {status: "SUCCESS" , message: "Loaded vehicles", data: @vehicles},status: :ok
  end

  # GET /api/v2/vehicles/1
  # GET /api/v2/vehicles/1.json
  def show
    render json: {status: "SUCCESS" , message: "Loaded vehicles", data: @vehicle},status: :ok
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
    @vehicle = Vehicle.new(vehicle_params)
    @vehicle.make_year = @vehicle.make_year.present? ? @vehicle.make_year : 2015
      if @vehicle.save(validate: false)
        render json: {status: "SUCCESS" , message: "saved vehicle", data: @vehicle},status: :ok
      else
        render json: {status: "ERROR" , message: "vehicle not saved", data: @vehicle.errors},status: :unprocessable_entity

      end
  end

  # PATCH/PUT /api/v2/vehicles/1
  # PATCH/PUT /api/v2/vehicles/1.json
  def update
   if @vehicle.update(vehicle_params)
      render json: {status: "SUCCESS" , message: "UPDATE SUCCESS", data: @vehicle},status: :ok
    else
      render json: {status: "ERROR" , message: "UPDATE FAIL", data: @vehicle.errors},status: :unprocessable_entity
    end
  end

  # DELETE /api/v2/vehicles/1
  # DELETE /api/v2/vehicles/1.json
  def destroy
    @vehicle.destroy
    render json: {status: "SUCCESS" , message: "Deleted vehicle", data: @vehicle},status: :ok
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
      params.permit(:business_associate_id, :plate_number, :model,:category,:seats,:ac, :colour,:puc_validity_date,:insurance_date,:permit_validity_date,:road_tax_validity_date,:authorization_certificate_validity_date,:fitness_validity_date )
    end
end


