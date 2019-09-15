class API::V2::BusinessAssociatesController < ApplicationController
  before_action :set_business_associate, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, unless: -> { ['devise_token_auth', 'overrides' ].include?(params[:controller].split('/')[0])}
  # GET /api/v2/business_associates
  # GET /api/v2/business_associates.json
  def index
    @business_associates = BusinessAssociate.all
    render json: {status: "True" , message: "Loaded business associates", data: { business_associates: @business_associates }, errors: {} }  ,status: :ok
  end

  # GET /api/v2/business_associate/1
  # GET /api/v2/business_associate/1.json
  def show
    @business_associate = BusinessAssociate.find(params[:id])
    render json: {status: "True" , message: "Loaded business associate", data: { business_associate: @business_associate }, errors: {} } ,status: :ok
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
        render json: {status: "True" , message: "saved business associate", data: { business_associate_id: @business_associate.id } , errors: {} }, status: :ok
      else
        render json: {status: "False" , message: "business associate not saved", data: {}, errors: @business_associate.errors }, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /api/v2/business_associate/1
  # PATCH/PUT /api/v2/business_associate/1.json
  def update
   if @business_associate.update(business_associate_params)
      render json: {status: "True" , message: "UPDATE SUCCESS", data: { business_associate_id: @business_associate,id } , errors: {}},status: :ok
    else
      render json: {status: "False" , message: "UPDATE FAIL", data: {}, errors: @business_associate.errors },status: :unprocessable_entity
    end
  end

  # DELETE /api/v2/vehicles/1
  # DELETE /api/v2/vehicles/1.json
  def destroy
    @business_associate.destroy
    render json: {status: "True" , message: "Deleted business associate", data: { business_associate_id: @business_associate.id }, errors: {}},status: :ok
  end


  def search
    if params["name"].present?
      search = params["name"]
        @result = BusinessAssociate.where('name LIKE ?', "%#{search}%")
        if @result.present?
          render json: { status: "True" , message: "Business Associate found", data: { business_associates: @result } , errors: {} },status: :ok
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
      params.permit(:sap_code, :legal_name,:business_type,:category, :esic_code,:pf_number, :service_tax_no,:pan, :aadhar_number, :credit_days, :credit_amount, :bgc_date, :credit_days_start, :owned_fleet, :managed_fleet, :turn_over, :partnership_status, :business_area_id, :address_1, :address_2, :admin_phone,:alternate_phone, :alternate_phone, :fax_no, :website, :hq_address,:status, :address_3, :bank_name, :bank_no, :ifsc_code, :city_of_operation, :state_of_operation, :ba_status, :cancelled_cheque_doc_url, :gst_certificates_doc_url, :cin_doc_url, :MSA_doc_url, :pan_card_doc_url, :msmed_certificate_doc_url, :photo_url, :owner_photo_url, :created_by, :updated_by. :admin_f_name, :admin_m_name, :admin_l_name, :tan, :name, :standard_price, :pay_period, :time_on_duty_limit, :distance_limit, :rate_by_time, :rate_by_distance, :invoice_frequency, :service_taxt_percent, :swachh_bharat_cess, :krishi_kalyan_cess, :logistics_company_id, :agreement_date)
    end
end
