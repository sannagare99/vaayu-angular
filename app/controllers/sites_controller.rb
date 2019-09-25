require 'services/google_service'

class SitesController < ApplicationController
  before_action :set_sites, only: [:update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.json { render json: SitesDatatable.new(view_context, current_user)}
    end
  end

  def new
    @site = Site.new
    @service = Service.new
    @vehicle_rate = VehicleRate.new
    @current_user = current_user
    @logistics_company_id = current_user&.entity&.logistics_company_id
  end

  def edit
    @site = Site.find_by_prefix(params[:id])
    render :new
  end

  def show
    @site = Site.find_by_prefix(params[:id])
    render json: { success: true , message: "Loaded site", data: { site: @site } , errors: {} },status: :ok
  end

  def details
    logistics_company_id = nil
    @site = Site.find_by_prefix(params[:id])
    @services = []

    if current_user.operator?
      logistics_company_id = current_user&.entity&.logistics_company&.id
      @services = Service.where(:site_id => params[:id]).where(:logistics_company_id => current_user.entity.logistics_company_id)
    elsif !params[:logistics_company_id].blank?
      logistics_company_id = params[:logistics_company_id]
      @services = Service.where(:site_id => params[:id]).where(:logistics_company_id => logistics_company_id)
    end

    @company = EmployeeCompany.where(:id => @site.employee_company_id).first
    @employee_companies = EmployeeCompany.all
    @logistics_companies = LogisticsCompany.all    
    @service_vehicles = {}
    @vehicle_zones = {}
    @vehicle_package_rates = {}
    @services.each do |service|
      @vehicle_rates = VehicleRate.where(:service_id => service.id)
      @vehicle_rates.each do |vehicle_rate|        
        @zone_rates = ZoneRate.where(:vehicle_rate_id => vehicle_rate.id)
        @vehicle_zones[vehicle_rate.id] = @zone_rates
        @package_rates = PackageRate.where(:vehicle_rate_id => vehicle_rate.id)
        @vehicle_package_rates[vehicle_rate.id] = @package_rates
      end
      @service_vehicles[service.id] = @vehicle_rates
    end
    @response = {
      :site => @site,
      :services => @services,
      :company => @company,
      :employee_companies => @employee_companies,
      :logistics_companies => @logistics_companies,
      :service_vehicles => @service_vehicles,
      :vehicle_zones => @vehicle_zones,
      :vehicle_package_rates => @vehicle_package_rates,
      :current_user_type => current_user.entity_type,
      :logistics_company_id => logistics_company_id
    }
    render :json => @response
  end

  # def get_service
  #   @site = Site.find_by_prefix(params[:site_id])
  #   @services = Service.where(:site_id => params[:site_id]).where(:logistics_company_id => params[:logistics_company_id])
  #   @company = EmployeeCompany.where(:id => @site.employee_company_id).first
  #   @employee_companies = EmployeeCompany.all
  #   @logistics_companies = LogisticsCompany.all
  #   logistics_company_id = ''
  #   @service_vehicles = {}
  #   @vehicle_zones = {}
  #   @vehicle_package_rates = {}
  #   @services.each do |service|
  #     @vehicle_rates = VehicleRate.where(:service_id => service.id)
  #     @vehicle_rates.each do |vehicle_rate|        
  #       @zone_rates = ZoneRate.where(:vehicle_rate_id => vehicle_rate.id)
  #       @vehicle_zones[vehicle_rate.id] = @zone_rates
  #       @package_rates = PackageRate.where(:vehicle_rate_id => vehicle_rate.id)
  #       @vehicle_package_rates[vehicle_rate.id] = @package_rates
  #     end
  #     @service_vehicles[service.id] = @vehicle_rates
  #   end

  #   if current_user.operator?
  #     logistics_company_id = current_user&.entity&.logistics_company&.id
  #   end
  #   @response = {
  #     :site => @site,
  #     :services => @services,
  #     :company => @company,
  #     :employee_companies => @employee_companies,
  #     :logistics_companies => @logistics_companies,
  #     :service_vehicles => @service_vehicles,
  #     :vehicle_zones => @vehicle_zones,
  #     :vehicle_package_rates => @vehicle_package_rates,
  #     :current_user_type => current_user.entity_type,
  #     :logistics_company_id => logistics_company_id
  #   }
  #   render :json => @response
  # end

  def create
    if current_user.operator? || current_user.admin?
      results = GoogleService.new.geocode(params[:site]['address']).first
      unless results.nil? || ! results.key?(:geometry)
        coordinates = results[:geometry][:location]
        latitude = coordinates[:lat]
        longitude = coordinates[:lng]
      end
      @site = Site.new(:name => params[:site]['name'], 
                      :employee_company_id => params[:site]['employee_company_id'],
                      :address  => params[:site]['address'],
                      :latitude => latitude,
                      :longitude => longitude,
                      :created_by => current_user.full_name,
                      :phone => params[:site]['phone'],
                      :city => params[:site]['city'],
                      :admin_name => params[:site]['admin_name'],
                      :admin_email_id => params[:site]['admin_email_id'],
                      :branch_name => params[:site]['branch_name'],
                      :contact_name => params[:site]['contact_name'],
                      :address_1 => params[:site]['address_1'],
                      :address_2 => params[:site]['address_2'],
                      :address_3 => params[:site]['address_3'],
                      :pin => params[:site]['pin'],
                      :state => params[:site]['state'],
                      :pan_no => params[:site]['pan_no'],
                      :gstin_no => params[:site]['gstin_no'],
                      :cost_centre => params[:site]['cost_centre'],
                      :profit_centre => params[:site]['profit_centre'],
                      :gl_acc_no => params[:site]['gl_acc_no'],
                      :party_code => params[:site]['party_code'],
                      :party_contact_name => params[:site]['party_contact_name'],
                      :party_address_1 => params[:site]['party_address_1'],
                      :party_address_3 => params[:site]['party_address_3'],
                      :party_address_2 => params[:site]['party_address_2'],
                      :party_pin => params[:site]['party_pin'],
                      :party_city => params[:site]['party_city'],
                      :party_state => params[:site]['party_state'],
                      :party_phone_1 => params[:site]['party_phone_1'],
                      :party_phone_2 => params[:site]['party_phone_2'],
                      :party_business_area => params[:site]['party_business_area'],
                      :party_pan_no => params[:site]['party_pan_no'],
                      :party_gstin_no => params[:site]['party_gstin_no']
                      )
      if @site.save
        params[:services].each do |service|
          @service = Service.create(:site_id => @site.id,
                                 :service_type => params[:services][service]['service_type'],
                                 :billing_model => params[:services][service]['billing_model'],
                                 :vary_with_vehicle => params[:services][service]['vary_with_vehicle'] == "false" ? false : true,
                                 :logistics_company_id => params[:site]['logistics_company_id']
                                )

          params[:services][service][:vehicles].each do |vehicle|
            @vehicle_rate = VehicleRate.create(:service_id => @service.id,
                                               :vehicle_capacity => params[:services][service][:vehicles][vehicle]['vehicle_capacity'],
                                               :ac => params[:services][service][:vehicles][vehicle]['ac'],
                                               :cgst => params[:services][service][:vehicles][vehicle]['cgst'],
                                               :sgst => params[:services][service][:vehicles][vehicle]['sgst']
                                               # :overage => params[:services][service][:vehicles][vehicle]['overage'],
                                               # :time_on_duty => params[:services][service][:vehicles][vehicle]['time_on_duty'],
                                               # :overage_per_hour => params[:services][service][:vehicles][vehicle]['overage_per_hour']
                                              )
            if !params[:services][service][:vehicles][vehicle][:zones].blank?
              params[:services][service][:vehicles][vehicle][:zones].each do |zone|                
                @zone_rate = ZoneRate.create(:vehicle_rate_id => @vehicle_rate.id,
                                             :name => params[:services][service][:vehicles][vehicle][:zones][zone]['name'],
                                             :rate => params[:services][service][:vehicles][vehicle][:zones][zone]['rate'],
                                             :guard_rate => params[:services][service][:vehicles][vehicle][:zones][zone]['guard_rate']
                                            )
              end  
            end

            if !params[:services][service][:vehicles][vehicle][:package_rate].blank?              
              @package_rate = PackageRate.create(:vehicle_rate_id => @vehicle_rate.id,
                                           :duration => params[:services][service][:vehicles][vehicle][:package_rate]['duration'],
                                           :package_duty_hours => params[:services][service][:vehicles][vehicle][:package_rate]['package_duty_hours'],
                                           :package_km => params[:services][service][:vehicles][vehicle][:package_rate]['package_km'],
                                           :package_overage_per_km => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_per_km'],
                                           :package_overage_per_time => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_per_time'],
                                           :package_mileage_calculation => params[:services][service][:vehicles][vehicle][:package_rate]['package_mileage_calculation'],
                                           :package_overage_time => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_time'],
                                           :package_rate => params[:services][service][:vehicles][vehicle][:package_rate]['package_rate']                                           
                                          )              
            end
          end
        end
      else
        flash[:error] = @site.errors.full_messages.to_sentence
      end 
      
    else
      flash[:error] = 'You have not permissions for create site'
    end

  end

  def update_site
    if current_user.admin? || current_user.operator?
      results = GoogleService.new.geocode(params[:site]['address']).first
      unless results.nil? || ! results.key?(:geometry)
        coordinates = results[:geometry][:location]
        latitude = coordinates[:lat]
        longitude = coordinates[:lng]
      end
      @site = Site.where(:id => params[:id]).first
      @site.update!(:name => params[:site]['name'], 
          :employee_company_id => params[:site]['employee_company_id'],
          :address  => params[:site]['address'],
          :phone  => params[:site]['phone'],
          :city => params[:site]['city'],
          :latitude => latitude,
          :longitude => longitude,
          :admin_name => params[:site][:admin_name],
          :admin_email_id => params[:site][:admin_email_id],
          :site_code => params[:site][:site_code],
          :branch_name => params[:site][:branch_name],
          :contact_name => params[:site][:contact_name],
          :address_1 => params[:site][:address_1],
          :address_2 => params[:site][:address_2],
          :address_3 => params[:site][:address_3],
          :pin => params[:site][:pin],
          :state => params[:site][:state],
          :phone_1 => params[:site][:phone_1],
          :phone_2 => params[:site][:phone_2],
          :pan_no => params[:site][:pan_no],
          :business_area => params[:site][:business_area],
          :gstin_no => params[:site][:gstin_no],
          :cost_centre => params[:site][:cost_centre],

          :profit_centre => params[:site][:profit_centre],
          :gl_acc_no => params[:site][:gl_acc_no],
          :party_contact_name => params[:site][:party_contact_name],
          :party_address_1 => params[:site][:party_address_1],
          :party_address_3 => params[:site][:party_address_3],
          :party_address_2 => params[:site][:party_address_2],
          :party_pin => params[:site][:party_pin],
          :party_city => params[:site][:party_city],
          :party_state => params[:site][:party_state],
          :party_phone_1 => params[:site][:party_phone_1],
          :party_phone_2 => params[:site][:party_phone_2],
          :party_business_area => params[:site][:party_business_area],
          :party_pan_no => params[:site][:party_pan_no],
          :party_gstin_no => params[:site][:party_gstin_no]
  )
      @site.updated_by = current_user.full_name if current_user.full_name.present?
      if !params[:site]['logistics_company_id'].blank?
        @services = Service.where(:site_id => @site.id).where(:logistics_company_id => params[:site]['logistics_company_id'])
        @services.each do |service|
          service.destroy
        end
        params[:services].each do |service|
          @service = Service.create(:site_id => @site.id,
                                 :service_type => params[:services][service]['service_type'],
                                 :billing_model => params[:services][service]['billing_model'],
                                 :vary_with_vehicle => params[:services][service]['vary_with_vehicle'] == "false" ? false : true,
                                 :logistics_company_id => params[:site]['logistics_company_id']
                                )

          params[:services][service][:vehicles].each do |vehicle|
            @vehicle_rate = VehicleRate.create(:service_id => @service.id,
                                               :vehicle_capacity => params[:services][service][:vehicles][vehicle]['vehicle_capacity'],
                                               :ac => params[:services][service][:vehicles][vehicle]['ac'],
                                               :cgst => params[:services][service][:vehicles][vehicle]['cgst'],
                                               :sgst => params[:services][service][:vehicles][vehicle]['sgst']
                                               # :overage => params[:services][service][:vehicles][vehicle]['overage'],
                                               # :time_on_duty => params[:services][service][:vehicles][vehicle]['time_on_duty'],
                                               # :overage_per_hour => params[:services][service][:vehicles][vehicle]['overage_per_hour']
                                              )
            if !params[:services][service][:vehicles][vehicle][:zones].blank?
              params[:services][service][:vehicles][vehicle][:zones].each do |zone|                
                @zone_rate = ZoneRate.create(:vehicle_rate_id => @vehicle_rate.id,
                                             :name => params[:services][service][:vehicles][vehicle][:zones][zone]['name'],
                                             :rate => params[:services][service][:vehicles][vehicle][:zones][zone]['rate'],
                                             :guard_rate => params[:services][service][:vehicles][vehicle][:zones][zone]['guard_rate']
                                            )
              end  
            end

            if !params[:services][service][:vehicles][vehicle][:package_rate].blank?              
              @package_rate = PackageRate.create(:vehicle_rate_id => @vehicle_rate.id,
                                           :duration => params[:services][service][:vehicles][vehicle][:package_rate]['duration'],
                                           :package_duty_hours => params[:services][service][:vehicles][vehicle][:package_rate]['package_duty_hours'],
                                           :package_km => params[:services][service][:vehicles][vehicle][:package_rate]['package_km'],
                                           :package_overage_per_km => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_per_km'],
                                           :package_overage_per_time => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_per_time'],
                                           :package_mileage_calculation => params[:services][service][:vehicles][vehicle][:package_rate]['package_mileage_calculation'],                                         
                                           :package_overage_time => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_time'],
                                           :package_rate => params[:services][service][:vehicles][vehicle][:package_rate]['package_rate']
                                          )
            end
          end
        end
      end      
    else
      flash[:error] = "You have not permissions for edit this site"
    end
  end

  def destroy
    if current_user.admin? || current_user.operator?
      @site.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
      flash[:notice] = "Site was successfully deleted."
    else
      render :json => { :errors => 'You have not permissions for delete this site' }
    end
  end

  private
    def set_sites
      @site = Site.find_by_prefix(params[:id])
    end

    def sites_params
      if params['data']
        params['site'] = params['data'].values.first
      end
      params.require(:site).permit(:id, :name, :address, :latitude, :longitude, :employee_company_id, :admin_name, :admin_email_id, :created_by, :updated_by, :phone, :site_code, :branch_name, :contact_name, :address_1, :address_2, :address_3, :pin, :state, :city, :phone_1, :phone_2, :pan_no, :business_area, :gstin_no, :cost_centre, :profit_centre, :gl_acc_no, :party_code, :party_contact_name, :party_address_1, :party_address_3, :party_address_2, :party_address_3, :party_pin, :party_city, :party_state, :party_phone_1, :party_phone_2, :party_business_area, :party_pan_no, :party_gstin_no)
      end
end
