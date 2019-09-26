class API::V2::BusinessAssociatesController < ApplicationController
  before_action :set_business_associate, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, unless: -> { ['devise_token_auth', 'overrides' ].include?(params[:controller].split('/')[0])}
  before_filter :restrict_access, only: [:create]
  # GET /api/v2/business_associates
  # GET /api/v2/business_associates.json
  def index
    @business_associates = BusinessAssociate.all
    render json: {success: true , message: "Loaded business associates", data: { business_associates: @business_associates }, errors: {} }  ,status: :ok
  end

  # GET /api/v2/business_associate/1
  # GET /api/v2/business_associate/1.json
  def show
    @business_associate = BusinessAssociate.find(params[:id])
    render json: {success: true , message: "Loaded business associate", data: { business_associate: @business_associate }, errors: {} } ,status: :ok
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
    if params[:ba_portal_id].present?
        @business_associate = BusinessAssociate.find_by_ba_portal_id(params[:ba_portal_id])
        @ba = field_mapper(params, @business_associate)
        if @ba.save
          render json: {success: true , message: "Successfully updated business associate", data: { business_associate_id: @business_associate.id } , errors: {} }, status: :ok
        else
          render json: {success: false , message: "Business associate not updated", data: {}, errors: @business_associate.errors.full_messages }, status: :ok
        end
      else
        @business_associate = BusinessAssociate.new(business_associate_params)
          if @business_associate.save(validate: false)
            render json: {success: true , message: "Successfully created business associate", data: { business_associate_id: @business_associate.id } , errors: {} }, status: :ok
          else
            render json: {success: false , message: "Business associate not saved", data: {}, errors: @business_associate.errors.full_messages }, status: :ok
          end
      end
  end

  # PATCH/PUT /api/v2/business_associate/1
  # PATCH/PUT /api/v2/business_associate/1.json
  def update
    @ba = field_mapper(params, @business_associate)
   if @ba.save
      render json: {success: true , message: "UPDATE SUCCESS", data: { business_associate_id: @business_associate.id } , errors: {} }  ,status: :ok 
    else
      render json: {success: false , message: "UPDATE FAIL", data: {}, errors: @business_associate.errors },status: :ok
    end
  end

  # DELETE /api/v2/vehicles/1
  # DELETE /api/v2/vehicles/1.json
  def destroy
    @business_associate.destroy
    render json: {success: true , message: "Deleted business associate", data: { business_associate_id: @business_associate.id }, errors: {} },status: :ok 
  end


  def search
    if params["name"].present?
      search = params["name"]
        @result = BusinessAssociate.where('name LIKE ?', "%#{search}%")
        if @result.present?
          render json: { success: true , message: "Business Associate found", data: { business_associates: @result } , errors: {} },status: :ok
        else
          render json: { success: false , message: "No Business Associate found", data: {}, errors: {} }, status: :ok
        end
    else
      render json: { success: "False" , message: "Please search business associate name", data: {}, errors: {} }, status: :ok
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_business_associate
      @business_associate = BusinessAssociate.find(params[:id])
      render json: {success: :ok} unless @business_associate
    end

    def restrict_access
      auth  = Authentication.exists?(x_api_key: request.headers["x-api-key"], portal: request.headers[:portal])
      render json: { success: :false ,head: :unauthorized, message: "Not authorized", data: {}, errors: {} } ,status: :ok unless auth
    end
  
    def field_mapper(params,business_associate)
      business_associate.admin_email = params[:emailId]
      business_associate.admin_phone = params[:mobileNo]
      business_associate.pan = params[:panNo]
      business_associate.address = params[:addressLine1]
      business_associate.address = params[:addressLine1]
      business_associate.address_2 = params[:addressLine2]
      business_associate.city_of_operation = params[:city]
      business_associate.state_of_operation = params[:state]
      business_associate.baId = params[:baId]
      business_associate.pin_code = params[:pinCode]
      business_associate.company_name = params[:companyName]
      business_associate.contact_person = params[:contactPerson]
      business_associate.cin_no = params[:cinNo]
      business_associate.landline = params[:landline]
      business_associate.contact_person_mobile = params[:contactPersonMobile]
      business_associate.approved_till_date = params[:approvedTill]
      business_associate.old_sap_master_code = params[:oldSapMasterCode]
      business_associate.new_sap_master_code = params[:newSapMasterCode]
      business_associate.ba_verified_on = params[:baVerifiedOn]
      business_associate.state_code = params[:stateCode]
      business_associate.cancelled_cheque_doc_url = params[:docs][0][:docPath]
      business_associate.pan_card_doc_url = params[:docs][3][:docPath]
      business_associate.msmed_certificate_doc_url = params[:docs][4][:docPath]
      business_associate.gstDocs = params["gstDocs"].to_json
      business_associate.is_gst = params[:isGst]
      business_associate.bussiness_area = params[:bussinessAera].to_a
      return business_associate
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def business_associate_params
      params.permit(:sap_code, :legal_name,:business_type,:category, :esic_code,:pf_number, :service_tax_no,:pan, :aadhar_number, :credit_days, :credit_amount, :bgc_date, :credit_days_start, :owned_fleet, :managed_fleet, :turn_over, :partnership_status, :business_area_id, :address_1, :address_2, :admin_phone,:alternate_phone, :alternate_phone, :fax_no, :website, :hq_address,:status, :address_3, :bank_name, :bank_no, :ifsc_code, :city_of_operation, :state_of_operation, :ba_status, :cancelled_cheque_doc_url, :gst_certificates_doc_url, :cin_doc_url, :MSA_doc_url, :pan_card_doc_url, :msmed_certificate_doc_url, :photo_url, :owner_photo_url, :created_by, :updated_by, :admin_f_name, :admin_m_name, :admin_l_name, :tan, :name, :standard_price, :pay_period, :time_on_duty_limit, :distance_limit, :rate_by_time, :rate_by_distance, :invoice_frequency, :service_taxt_percent, :swachh_bharat_cess, :krishi_kalyan_cess, :logistics_company_id, :agreement_date, :ba_portal_id )
    end
end
