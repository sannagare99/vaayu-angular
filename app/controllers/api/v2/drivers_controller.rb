class API::V2::DriversController < ApplicationController
  before_action :set_driver, only: [:edit, :update, :destroy, :show]
  skip_before_action :authenticate_user!
  before_action :check_date_validation, only: [:create]
  before_action :check_date_of_birth, only: [:create]
  before_action :check_badge_expire_date, :validate_birth_date, only: [:create]
  before_action :check_gender, :validate_birth_date, only: [:create]
  before_action :check_badge_number, :validate_birth_date, only: [:create]
  # before_action :check_f_name_validate, only: [:create]
  # GET /api/v2/drivers
  # GET /api/v2/drivers.json
  def index
    @drivers = Driver.all
    render json: {success: true , message: "Loaded drivers", data: { drivers: @drivers } , errors: {}},status: :ok
  end

  # GET /api/v2/drivers/1
  # GET /api/v2/drivers/1.json
  def show
    if @driver.present?
      render json: { success: true , message: "Loaded driver", data: { driver: @driver } , errors: {} },status: :ok
    else
      render json: { success: false , message: "No driver found", data: {}, errors: {} }, status: :ok
    end
  end

  # GET /api/v2/drivers/new
  def new
    @driver = Driver.new
  end

  # GET /api/v2/drivers/1/edit
  def edit
  end

  # POST /api/v2/drivers
  # POST /api/v2/drivers.json
  def create
    if params[:registration_steps] == "Step_1"
      user =  User.new
      user.role = 3
      set_driver_user_field(user,params)
    elsif params[:registration_steps] == "Step_2"
      @driver = Driver.find(params[:driver_id]) if params[:driver_id].present?
      if validate_first_step(@driver) == true

        if @driver.update(driver_params.except!(:registration_steps))
          @driver.update_attribute('registration_steps', 'Step_2')
          render json: {success: true , message: "Success Second step", data: { driver_id: @driver.id }, errors: {} }, status: :ok if @driver.id.present?
        else
          render json: {success: false , message: "Fail Second step", data: {}, errors: { errors: @driver.errors.full_messages } },status: :ok
        end
      else
        render json: {success: false , message: "Please complete Step 1 form", data: {}, errors: { errors: validate_first_step(@driver) } },status: :ok
      end
    elsif params[:registration_steps] == "Step_3"
      @driver = Driver.find(params[:driver_id]) if params[:driver_id].present?
        if params[:driving_registration_form_doc].blank? or params[:driver_badge_doc].blank? or params[:driving_license_doc].blank? or params[:id_proof_doc].blank? or params[:medically_certified_doc].blank? or params[:bgc_doc].blank? or params[:sexual_policy_doc].blank? or params[:police_verification_vailidty_doc].blank?
         render json: {success: false , message: "Please Upload all docs", data: {}, errors: {},status: :ok }
      else
        if validate_first_and_second_step(@driver) == true
          if @driver.update(driver_params)
            @driver.update_attribute('registration_steps', 'Step_3')
            upload_driver_badge_doc(@driver) if @driver.present?
            upload_driving_license_doc(@driver) if @driver.present?
            upload_id_proof_doc(@driver) if @driver.present?
            upload_driving_registration_form_doc(@driver) if @driver.present?
            # upload_profile_picture_url(@driver) if @driver.present?
            upload_police_verification_vailidty_doc(@driver) if @driver.present?
            upload_sexual_policy_doc(@driver) if @driver.present?
            upload_police_verification_vailidty_doc(@driver) if @driver.present?
            upload_bgc_doc(@driver) if @driver.present?
            upload_medically_certified_doc(@driver) if @driver.present?
            @driver.update(induction_status: "Registered")
            @driver.update(compliance_status: "Ready For Allocation")
            @driver.update(date_of_registration: Time.now )
            render json: {success: true , message: "Success Final step", data: { driver_id: @driver.id } , errors: {} }, status: :ok if @driver.id.present?
          else
            render json: {success: false , message: "Fail Final step", data: {}, errors: { errors: @driver.errors.split(",") } },status: :ok
          end
      else
        render json: {success: false , message: "Please complete Step 1 and 2 form", data: {}, errors: { errors: validate_first_and_second_step(@driver) } },status: :ok
      end
    end
    else 
      render json: {success: true , message: "You have not used", data: { driver: @driver } },status: :ok
    end
  end

  # PATCH/PUT /api/v2/drivers/1
  # PATCH/PUT /api/v2/drivers/1.json
  def update
    if @driver.update(driver_params)
      render json: {success: true , message: "UPDATE SUCCESS", data: { driver: @driver} },status: :ok
    else
      render json: {success: false , message: "UPDATE FAIL", data: @driver.errors.split(",")},status: :ok
    end
  end

  # DELETE /api/v2/drivers/1.json
  def destroy
    @driver.destroy
    render json: {success: true , message: "Deleted driver", data: { driver: @driver } },status: :ok
  end

    api :POST, '/drivers/:id/update_current_location'
    description 'Update the current location for on duty driver and send a push to all employees on that trip for real time update'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'Driver not found'
    example'
    {
      "success": true,
      "updatedETA": "updated ETA"
    }'
    def update_current_location
      authorize! :read, @driver

      trip_id = ""
      @trip_array = []
      params["values"].each do |location|
        if trip_id != location["nameValuePairs"]["tripId"]
          trip_id = location["nameValuePairs"]["tripId"]
          @trip = Trip.where(id: trip_id).first
          if !@trip.blank?    
            @trip_array.push(@trip)
          else
            next
          end
        end
        if !@trip.blank?
          @trip.set_trip_location({:lat => location["nameValuePairs"]["lat"].to_f, :lng => location["nameValuePairs"]["lng"].to_f}, location["nameValuePairs"]["distance"], location["nameValuePairs"]["speed"], location["nameValuePairs"]["time"])
        end
      end

      render '_success', status: 200
    end

    api :GET, '/drivers/:id/last_trip_request'
    description 'Get latest available trip request. Will be deprecated when push notifications would be done'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'Driver not found'
    example'
    {
      "id": 2,
      "status": "assign_requested",
      "trip_type": "check_in",
      "date": 1479106800
    }'
    def last_trip_request
      authorize! :read, @driver

      @trip = @driver.trips.where(:id => params[:trip_id]).where(:status => ['assign_requested', 'assign_request_expired']).order(assign_request_expired_date: :asc).last
    end

    def vehicle_info
      @vehicles = Vehicle.where("replace(lower(plate_number), ' ', '') LIKE replace(?, ' ', '')", "%#{params[:vehicle_id]}%")
      puts @vehicles
      if @vehicles.blank?
        render '_errors', status:422
      end
    end


    def search
      if params["type"].present? and params["search"].present?
        search = params["search"]
        if params["type"] == "vehicle"
          @result = Vehicle.where('plate_number LIKE ?', "%#{search}%")
        elsif params["type"] == "driver"
          @result = Driver.where("licence_number LIKE ?" , "%#{search}%")
        else
          render json: {status: :ok} 
        end
        render json: @result.to_json, status: :ok
      else
        render json: Vehicle.all.to_json, status: :ok
      end
    end

    def validate_licence_number
      if params[:licence_number].present?
        result = Driver.pluck(:licence_number).include? params[:licence_number]
        render json: {success: true , message: "license number should not be duplicate", data: { licence_number: params[:licence_number] }  , errors: {} }, status: :not_found if result
        render json: { success: false , message: "License number is unique", data: { licence_number: params[:licence_number] }, errors: {} }, status: :ok if result == false
      end
    end

  protected
    # Never trust parameters from the scary internet, only allow the white list through.

    def set_driver_user_field(user,params)
      user.phone = params[:aadhaar_mobile_number].present? ? params[:aadhaar_mobile_number] : nil
      user.entity.licence_number = params[:licence_number].present? ? params[:licence_number] : nil
      user.entity.date_of_birth = params[:date_of_birth] if params[:date_of_birth].present?
      user.entity.aadhaar_mobile_number = params[:aadhaar_mobile_number].present? ? params[:aadhaar_mobile_number] : nil
      user.entity.father_spouse_name = params[:father_spouse_name] if params[:father_spouse_name].present?
      user.entity.blood_group = params[:blood_group] if params[:blood_group].present?
      user.entity.business_associate_id = params[:business_associate_id] if params[:business_associate_id].present?
      user.entity.gender = params[:gender] if params[:gender].present?
      user.entity.profile_picture  = params[:profile_picture] if params[:profile_picture].present?
      user.entity.profile_picture_url = "#{user.entity.profile_picture.url.gsub("//",'')}" if user.entity.profile_picture.present?
      user.entity.business_state = "validate"
      user.entity.induction_status = "Draft"
      # user.entity.registration_steps = params[:registration_steps] if params[:registration_steps].present?
      # user.f_name = params[:f_name] if params[:f_name].present?
      # user.l_name = params[:l_name] if params[:l_name].present?
      # user.entity.f_name = params[:f_name] if params[:f_name].present?
      # user.entity.l_name =  params[:l_name] if params[:l_name].present?
      user.entity.registration_steps = 'Step_1'
      user.entity.driver_name = params[:f_name] + ' ' + (params[:l_name].present? ? params[:l_name] : '')
      user.save_with_notify_for_driver
      @errors = user.errors.full_messages.to_sentence
      @datatable_name = "drivers"
      if @errors.present?
        render json: {success: false , message: "Fail First step", data: {}, errors: @errors.split(",") },status: :ok
      else
        render json: { success: true , message: "Success First step", data: { driver_id: user.entity.id } , errors: {} }, status: :ok
      end

    end

  def upload_driver_badge_doc(driver)
    if driver.driver_badge_doc.url.present?
      driver.update(driver_badge_doc_url: driver.driver_badge_doc.url.gsub("//",''))
      DocumentRenewalRequest.create(status: "Renew", resource_id: driver.id, document_id: "7", document_url: "#{driver.driver_badge_doc.url.gsub("//",'')}", expiry_date: driver.badge_expire_date , created_by: 0, resource_type: "Driver" ) if driver.badge_expire_date.present?
    end 
  end

  def upload_driving_license_doc(driver)
    if driver.driving_license_doc.url.present?
      driver.update(driving_license_doc_url: driver.driving_license_doc.url.gsub("//",''))
      DocumentRenewalRequest.create(status: "Renew", resource_id: driver.id, document_id: "2", document_url: "#{driver.driving_license_doc.url.gsub("//",'')}", expiry_date: driver.licence_validity , created_by: 0, resource_type: "Driver" ) if driver.licence_validity.present?
    end
  end

  def upload_id_proof_doc(driver)
    if driver.id_proof_doc.url.present?
      driver.update(id_proof_doc_url: driver.id_proof_doc.url.gsub("//",''))
    end
  end

  def upload_driving_registration_form_doc(driver)
    if driver.driving_registration_form_doc.url.present?
      driver.update(driving_registration_form_doc_url: driver.driving_registration_form_doc.url.gsub("//",''))
    end
  end

  def upload_sexual_policy_doc(driver)
    if driver.sexual_policy_doc.url.present?
      driver.update(sexual_policy_doc_url: driver.sexual_policy_doc.url.gsub("//",''))
    end
  end

  def upload_profile_picture_url(driver)
    if driver.profile_picture.url.present?
      driver.update(profile_picture_url: driver.profile_picture.url.gsub("//",''))
    end
  end

  def upload_police_verification_vailidty_doc(driver)
    if driver.police_verification_vailidty_doc.url.present?
      driver.update(police_verification_vailidty_doc_url: driver.police_verification_vailidty_doc.url.gsub("//",''))
    end
  end

  def upload_medically_certified_doc(driver)
    if driver.medically_certified_doc.url.present?
      driver.update(medically_certified_doc_url: driver.medically_certified_doc.url.gsub("//",''))
    end
  end

  def upload_bgc_doc(driver)
    if driver.bgc_doc.url.present?
      driver.update(bgc_doc_url: driver.bgc_doc.url.gsub("//",''))
    end
  end

  # def upload_profile_picture_url(driver)
  #   if driver.profile_picture.url.present?
  #     driver.update(profile_picture_url: driver.profile_picture.url.gsub("//",''))
  #   end
  # end

    def set_driver
      @driver = Driver.find_by(params[:id])
      render json: {status: :ok} unless @driver
    end

    def check_badge_expire_date
      if params[:registration_steps] == "Step_2"
        if params[:badge_expire_date].present? && params[:badge_expire_date].to_date < Date.today 
          render json: {success: false , message: "Your Badge has expired", data: {}, errors: "Record not updated",status: :ok}
        end
      end
    end

  ### Step1 date validation 
    def validate_birth_date
      if params[:registration_steps] == "Step_1"
        if params[:date_of_birth].present? && params[:date_of_birth].to_date > Date.today 
          render json: {success: false , message: "Your DOB is wrong", data: {}, errors: "Record not updated",status: :ok }
        end
      end
    end

    def check_date_validation
      if params[:registration_steps] == "Step_2"
        if params[:licence_validity].present? && params[:licence_validity].to_date < Date.today 
          render json: {success: false , message: "Your Licence has expired", data: {}, errors: "Record not updated",status: :ok }
        elsif params[:licence_validity].blank?
          render json: {success: false , message: "Please enter birth date.", data: {}, errors: "Record not updated",status: :ok }
        end
      end
    end

    def check_date_of_birth
      if params[:registration_steps] == "Step_1"
        if params[:date_of_birth].present? && params[:date_of_birth].to_date > Date.today
          render json: {success: false , message: "Birth date  should less then today date.", data: {}, errors: "Record not updated",status: :ok }
        elsif params[:date_of_birth].blank?
          render json: {success: false , message: "Please enter birth date.", data: {}, errors: "Record not updated",status: :ok }
        end
      end
    end

    def check_gender
      if params[:registration_steps] == "Step_1"
        if params[:gender].blank?
          render json: {success: false , message: "Please enter gender.", data: {}, errors: "Record not updated",status: :ok }
        end
      end
    end


    def check_badge_number
      if params[:registration_steps] == "Step_2"
        if params[:badge_number].blank?
          render json: {success: false , message: "Please enter Badge number.", data: {}, errors: "Record not updated",status: :ok }
        end
      end
    end

    # def check_f_name_validate
    #   if params[:registration_steps] == "Step_1"
    #     if params[:f_name].blank?
    #       render json: {success: false , message: "First name can't be blank", data: {}, errors: "Record not updated",status: :ok }
    #     end
    #   end
    # end

    def validate_first_step(driver)
      result = {}
      Driver::STEP_DRIVER[:Step_1].each do |i|
        other_result = { i => driver[i].present? } 
        result.merge!(other_result)
      end
      return true
    end

    def validate_first_and_second_step(driver)
      result = {}
      drivers_step = Driver::STEP_DRIVER[:Step_1].concat Driver::STEP_DRIVER[:Step_2]
      drivers_step.each do |i|
        other_result = { i => driver[i].present? } 
        result.merge!(other_result)
      end
      return true
    end

    def driver_params
      # params.permit(:business_associate_id, :licence_number, :aadhaar_mobiformat: { with: /\A[a-z]*\z/i, message:  "Name must only contain letters." },le_number,:date_of_birth,:marital_status,:gender,:blood_group, :driver_name, :father_spouse_name, :alternate_number, :licence_type, :licence_validity, :local_address, :permanent_address, :total_experience,:business_state, :business_city, :qualification, :date_of_registration, :badge_number, :badge_issue_date,:badge_expiry_date, :verified_by_police, :police_verification_vailidty,:date_of_police_verification, :criminal_offence, :bgc_date, :bgc_agency_id, :medically_certified_date, :sexual_policy, :bank_name, :bank_no, :ifsc_code, :status, :blacklisted, :driving_license_doc_url, :driver_badge_doc_url, :id_proof_doc_url, :sexual_policy_doc_url,:police_verification_vailidty_doc_url,:medically_certified_doc_url, :bgc_doc_url,:profile_picture_url,:other_docs_url,:driving_registration_form_doc_url, :created_by, :updated_by,
      #   :site_id )
      params.permit(:business_associate_id, :licence_number, :driver_name, :alternate_number,:date_of_birth,:father_spouse_name, :gender, :blood_group, :licence_type, :licence_validity, :badge_number, :badge_expire_date, :ifsc_code,:bank_name, :bank_no,:profile_picture_url,:driver_badge_doc_url,:driving_license_doc_url,:id_proof_doc_url,:driving_registration_form_doc_url,:business_city,:business_state,:registration_steps, :aadhaar_mobile_number,:driving_license_doc, :driver_badge_doc, :id_proof_doc, :driving_registration_form_doc,  :profile_picture, :police_verification_vailidty_doc, :police_verification_vailidty_doc_url, :sexual_policy_doc, :sexual_policy_doc_url, :medically_certified_doc, :medically_certified_doc_url, :bgc_doc, :bgc_doc_url )
    end
end