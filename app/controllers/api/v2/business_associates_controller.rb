class API::V2::BusinessAssociatesController < ApplicationController
  before_action :set_business_associate, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, unless: -> { ['devise_token_auth', 'overrides' ].include?(params[:controller].split('/')[0])}
  # GET /api/v2/business_associates
  # GET /api/v2/business_associates.json
  def index
    @business_associates = BusinessAssociate.all
    render json: {status: "SUCCESS" , message: "Loaded business associates", data: { business_associates: @business_associates } }  ,status: :ok
  end

  # GET /api/v2/business_associate/1
  # GET /api/v2/business_associate/1.json
  def show
    render json: {status: "SUCCESS" , message: "Loaded business associate", data: @business_associate},status: :ok
  end

  # GET /api/v2/business_associate/new
  def new
    @business_associate = BusinessAssociate.new
  end

  # GET /api/v2/business_associate/1/edit
  def edit
  end

  # POST /api/v2/business_associate
  # POST /api/v2/business_associate.json
  def create
    @business_associate = BusinessAssociate.new(business_associate_params)
      if @business_associate.save(validate: false)
        render json: {status: "SUCCESS" , message: "saved business associate", data: @business_associate},status: :ok
      else
        render json: {status: "ERROR" , message: "business associate not saved", data: @business_associate.errors},status: :unprocessable_entity
      end
  end

  # PATCH/PUT /api/v2/business_associate/1
  # PATCH/PUT /api/v2/business_associate/1.json
  def update
   if @business_associate.update(business_associate_params)
      render json: {status: "SUCCESS" , message: "UPDATE SUCCESS", data: @business_associate},status: :ok
    else
      render json: {status: "ERROR" , message: "UPDATE FAIL", data: @business_associate.errors},status: :unprocessable_entity
    end
  end

  # DELETE /api/v2/vehicles/1
  # DELETE /api/v2/vehicles/1.json
  def destroy
    @business_associate.destroy
    render json: {status: "SUCCESS" , message: "Deleted business associate", data: @business_associate},status: :ok
  end


  def search
    if params["name"].present?
      search = params["name"]
        @result = BusinessAssociate.where('name LIKE ?', "%#{search}%")
        if @result.present?
          render json: { status: "True" , message: "Business Associate found", data: { driver: @result } , errors: {} },status: :ok
        else
          render json: { status: "False" , message: "No Business Associate found", data: {}, errors: {} }, status: :not_found
        end
    else
      render json: { status: "False" , message: "Please search business associate name", data: {}, errors: {} }, status: :not_found
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_business_associate
      @business_associate = BusinessAssociate.find(params[:id])
      render json: {status: :not_found} unless @business_associate
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def business_associate_params
      params.permit(:sap_code, :esic_code,:category,:esic_code,:pf_number,:service_tax_no,:pan,:aadhar_number,:credit_days,:credit_amount,:bgc_date,:credit_days_start,:owned_fleet,:managed_fleet,
        :turn_over,:partnership_status,:business_area_id,:address_1,:address_2,:admin_phone,:alternate_phone,:admin_email,:fax_no,:website,:hq_address,:status,:agreement_date,:bank_name,:bank_no,:ifsc_code,:city_of_operation,:ba_status,:cancelled_cheque_doc_url,:updated_by,:created_by,:owner_photo_url,:photo_url,:cin_doc_url,:MSA_doc_url,:pan_card_doc_url,:msmed_certificate_doc_url)
    end
end
