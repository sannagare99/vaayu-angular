class API::V2::DriversController < ApplicationController
  before_action :set_driver, only: [:show, :edit, :update, :destroy, :create]
  # GET /api/v2/drivers
  # GET /api/v2/drivers.json
  def index
    @drivers = Driver.all
    render json: {status: "True" , message: "Loaded drivers", data: @drivers},status: :ok
  end

  # GET /api/v2/drivers/1
  # GET /api/v2/drivers/1.json
  def show
    if @driver.present?
      render json: {status: "True" , message: "Loaded driver", data: @driver, errors: {} },status: :ok
    else
      render json: {status: "False" , message: "No driver found", data: {}, errors: {} }, status: :not_found
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
      user.entity.update(profile_picture_url: user.avatar.url) if user.avatar.url.present?
    elsif params[:registration_steps] == "Step_2"
      @driver = Driver.find(params[:driver_id]) if params[:driver_id].present?
        if @driver.update(driver_params)
          render json: {status: "True" , message: "Success Second step", data: @driver.id, errors: {} }, status: :ok if @driver.id.present?
        else
          render json: {status: "False" , message: "Fail Second step", data: {}, errors: @driver.errors },status: :unprocessable_entity if @driver.id.blank?
      end
    elsif params[:registration_steps] == "Step_3"
      @driver = Driver.find(params[:driver_id]) if params[:driver_id].present?
        if @driver.update(driver_params)
            upload_driver_badge_doc(@driver) if @driver.present?
            upload_driving_license_doc(@driver) if @driver.present?
            upload_id_proof_doc(@driver) if @driver.present?
            upload_driving_registration_form_doc(@driver) if @driver.present?
          render json: {status: "True" , message: "Success Final step", data: @driver.id, errors: {} }, status: :ok if @driver.id.present?
        else
          render json: {status: "False" , message: "Fail Final step", data: {}, errors: @driver.errors },status: :unprocessable_entity if @driver.id.blank?
        end
    else 
      render json: {status: "True" , message: "Noy used", data: @driver},status: :ok
    end
  end

  # PATCH/PUT /api/v2/drivers/1
  # PATCH/PUT /api/v2/drivers/1.json
  def update
    if @driver.update(driver_params)
      render json: {status: "True" , message: "UPDATE SUCCESS", data: @driver},status: :ok
    else
      render json: {status: "False" , message: "UPDATE FAIL", data: @driver.errors},status: :unprocessable_entity
    end
  end

  # DELETE /api/v2/drivers/1.json
  def destroy
    @driver.destroy
    render json: {status: "True" , message: "Deleted driver", data: @driver},status: :ok
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
          render json: {status: :not_found} 
        end
        render json: @result.to_json, status: :ok
      else
        render json: Vehicle.all.to_json, status: :ok
      end
    end

  protected
    # Never trust parameters from the scary internet, only allow the white list through.

    def set_driver_user_field(user,params)
      user.phone = params[:aadhaar_mobile_number].present? ? params[:aadhaar_mobile_number] : nil
      user.entity.licence_number = params[:licence_number].present? ? params[:licence_number] : nil
      user.entity.date_of_birth = params[:date_of_birth] if params[:date_of_birth].present?
      user.avatar = params[:profile_picture_url] if params[:profile_picture_url].present?
      user.entity.business_state = "validate"
      user.entity.induction_status = "Draft"
      user.entity.registration_steps = params[:registration_steps] if params[:registration_steps].present?
      user.f_name = params[:driver_name].split().first if params[:driver_name].present?
      user.l_name = params[:driver_name].split().last if params[:driver_name].present?
      user.save_with_notify_for_driver
      @errors = user.errors.full_messages.to_sentence
      @datatable_name = "drivers"
      if @errors.present?
        render json: {status: "False" , message: "Fail First step", data: {}, errors: @errors },status: :unprocessable_entity
      else
        render json: { status: "True" , message: "Success First step", data: user.entity.id, errors: {} }, status: :ok
      end

    end

  def upload_driver_badge_doc(driver)
    if driver.driver_badge_doc.url.present?
      driver.update(driver_badge_doc_url: driver.driver_badge_doc.url.gsub("//",''))
    end 
  end

  def upload_driving_license_doc(driver)
    if driver.driving_license_doc.url.present?
      driver.update(driving_license_doc_url: driver.driving_license_doc.url.gsub("//",''))
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

    def set_driver
      @driver = Driver.find_by(params[:id])
      render json: {status: :not_found} unless @driver
    end

    def driver_params
      # params.permit(:business_associate_id, :licence_number, :aadhaar_mobile_number,:date_of_birth,:marital_status,:gender,:blood_group, :driver_name, :father_spouse_name, :alternate_number, :licence_type, :licence_validity, :local_address, :permanent_address, :total_experience,:business_state, :business_city, :qualification, :date_of_registration, :badge_number, :badge_issue_date,:badge_expiry_date, :verified_by_police, :police_verification_vailidty,:date_of_police_verification, :criminal_offence, :bgc_date, :bgc_agency_id, :medically_certified_date, :sexual_policy, :bank_name, :bank_no, :ifsc_code, :status, :blacklisted, :driving_license_doc_url, :driver_badge_doc_url, :id_proof_doc_url, :sexual_policy_doc_url,:police_verification_vailidty_doc_url,:medically_certified_doc_url, :bgc_doc_url,:profile_picture_url,:other_docs_url,:driving_registration_form_doc_url, :created_by, :updated_by,
      #   :site_id )
      params.permit(:business_associate_id, :licence_number, :driver_name, :alternate_number,:date_of_birth,:father_spouse_name, :gender, :blood_group, :licence_type, :licence_validity, :badge_number, :badge_expire_date, :ifsc_code,:bank_name, :bank_no,:profile_picture_url,:driver_badge_doc_url,:driving_license_doc_url,:id_proof_doc_url,:driving_registration_form_doc_url,:business_city,:business_state,:registration_steps, :aadhaar_mobile_numbe,:driving_license_doc, :driver_badge_doc, :id_proof_doc, :driving_registration_form_doc )
    end
end