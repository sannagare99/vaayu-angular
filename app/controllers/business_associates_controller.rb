class BusinessAssociatesController < ApplicationController
  before_action :set_b_a, only: [:edit, :update, :destroy]
  
  def index
    @business_associates = BusinessAssociate.all
    respond_to do |format|
      format.html
      format.json { render json: BusinessAssociatesDatatable.new(view_context, current_user) }
    end
  end


  def new
    @business_associate = BusinessAssociate.new
    @current_user = current_user
    @logistics_company_id = current_user&.entity&.logistics_company_id
  end

  def create
    if current_user.operator? || current_user.admin?      
      @business_associate = BusinessAssociate.new(
                          :admin_f_name => params[:ba]['admin_f_name'],
                          :admin_m_name => params[:ba]['admin_m_name'],
                          :admin_l_name => params[:ba]['admin_l_name'],
                          :admin_email => params[:ba]['admin_email'],
                          :admin_phone => params[:ba]['admin_phone'],
                          :name => params[:ba]['name'],
                          :legal_name => params[:ba]['legal_name'],
                          :pan => params[:ba]['pan'],
                          :tan => params[:ba]['tan'],
                          :business_type => params[:ba]['business_type'],
                          :service_tax_no => params[:ba]['service_tax_no'],
                          :hq_address => params[:ba]['hq_address']
                      )
      if @business_associate.save
        params[:services].each do |service|
          @service = BaService.create(:business_associate_id => @business_associate.id,
                                 :service_type => params[:services][service]['service_type'],
                                 :billing_model => params[:services][service]['billing_model'],
                                 :vary_with_vehicle => params[:services][service]['vary_with_vehicle'] == "false" ? false : true,
                                 :logistics_company_id => params[:ba]['logistics_company_id']
                                )

          params[:services][service][:vehicles].each do |vehicle|
            @vehicle_rate = BaVehicleRate.create(:ba_service_id => @service.id,
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
                @zone_rate = BaZoneRate.create(:ba_vehicle_rate_id => @vehicle_rate.id,
                                             :name => params[:services][service][:vehicles][vehicle][:zones][zone]['name'],
                                             :rate => params[:services][service][:vehicles][vehicle][:zones][zone]['rate'],
                                             :guard_rate => params[:services][service][:vehicles][vehicle][:zones][zone]['guard_rate']
                                            )
              end
            end
            if !params[:services][service][:vehicles][vehicle][:package_rate].blank?              
              @package_rate = BaPackageRate.create(:ba_vehicle_rate_id => @vehicle_rate.id,
                                           :duration => params[:services][service][:vehicles][vehicle][:package_rate]['duration'],
                                           :package_duty_hours => params[:services][service][:vehicles][vehicle][:package_rate]['package_duty_hours'],
                                           :package_km => params[:services][service][:vehicles][vehicle][:package_rate]['package_km'],
                                           :package_overage_per_km => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_per_km'],
                                           :package_overage_per_time => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_per_time'],
                                           :package_mileage_calcultation => params[:services][service][:vehicles][vehicle][:package_rate]['package_mileage_calcultation'],
                                           :package_overage_time => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_time'],
                                           :package_rate => params[:services][service][:vehicles][vehicle][:package_rate]['package_rate']
                                          )
            end
          end
        end
        # -----------------------
        # @business_associate.logistics_company = current_user.entity&.logistics_company
        # -----------------------
      else
        flash[:error] = @business_associate.errors.full_messages.to_sentence
      end 


      # if @business_associate.save
      #   flash[:notice] = 'Business Associate was successfully created'
      # else
      #   flash[:error] = @business_associate.errors.full_messages.to_sentence
      # end
    else
      flash[:error] = 'You have not permissions for create business associate'
    end
    # redirect_to provisioning_path(anchor: 'business-associates')
  end

  def show
    @business_associate = BusinessAssociate.find(params[:id])
  end

  def edit
    @ba = BusinessAssociate.find_by_prefix(params[:id])
    render :new
  end

  def details
    logistics_company_id = nil
    @ba = BusinessAssociate.find_by_prefix(params[:id])
    @services = []

    if current_user.operator?
      logistics_company_id = current_user&.entity&.logistics_company&.id
      @services = BaService.where(:business_associate_id => params[:id]).where(:logistics_company_id => current_user.entity.logistics_company_id)
    elsif !params[:logistics_company_id].blank?
      logistics_company_id = params[:logistics_company_id]
      @services = BaService.where(:business_associate_id => params[:id]).where(:logistics_company_id => logistics_company_id)
    end



    @service_vehicles = {}
    @vehicle_zones = {}
    @vehicle_package_rates = {}
    @logistics_companies = LogisticsCompany.all
    
    @services.each do |service|
      @vehicle_rates = BaVehicleRate.where(:ba_service_id => service.id)
      @vehicle_rates.each do |vehicle_rate|        
        @zone_rates = BaZoneRate.where(:ba_vehicle_rate_id => vehicle_rate.id)
        @vehicle_zones[vehicle_rate.id] = @zone_rates
        @package_rates = BaPackageRate.where(:ba_vehicle_rate_id => vehicle_rate.id)
        @vehicle_package_rates[vehicle_rate.id] = @package_rates
      end
      @service_vehicles[service.id] = @vehicle_rates
    end

    if current_user.operator?
      logistics_company_id = current_user&.entity&.logistics_company&.id
    end

    @response = {
      :ba => @ba,
      :services => @services,
      :service_vehicles => @service_vehicles,
      :vehicle_zones => @vehicle_zones,
      :vehicle_package_rates => @vehicle_package_rates,
      :current_user_type => current_user.entity_type,
      :logistics_company_id => logistics_company_id,
      :logistics_companies => @logistics_companies
    }
    render :json => @response
  end

  def update
    if current_user.admin? || current_user.operator?
      if @business_associate.update(ba_params)
        flash[:notice] = 'Business Associate was successfully updated'
      else
        flash[:error] = @business_associate.errors.full_messages.to_sentence
      end
    else
      flash[:error] = 'You have not permissions for edit object'
    end
    redirect_to provisioning_path(anchor: 'business-associates')
  end

  def update_ba
    if current_user.operator? || current_user.admin?
      @business_associate = BusinessAssociate.where(:id => params[:id]).first
      @business_associate.update!(
                          :admin_f_name => params[:ba]['admin_f_name'],
                          :admin_m_name => params[:ba]['admin_m_name'],
                          :admin_l_name => params[:ba]['admin_l_name'],
                          :admin_email => params[:ba]['admin_email'],
                          :admin_phone => params[:ba]['admin_phone'],
                          :name => params[:ba]['name'],
                          :legal_name => params[:ba]['legal_name'],
                          :pan => params[:ba]['pan'],
                          :tan => params[:ba]['tan'],
                          :business_type => params[:ba]['business_type'],
                          :service_tax_no => params[:ba]['service_tax_no'],
                          :hq_address => params[:ba]['hq_address']
                      )
      if !params[:ba]['logistics_company_id'].blank?
        @services = BaService.where(:business_associate_id => @business_associate.id).where(:logistics_company_id => params[:ba]['logistics_company_id'])
        @services.each do |service|
          service.destroy
        end
        params[:services].each do |service|          
          @service = BaService.create(:business_associate_id => @business_associate.id,
                                 :service_type => params[:services][service]['service_type'],
                                 :billing_model => params[:services][service]['billing_model'],
                                 :vary_with_vehicle => params[:services][service]['vary_with_vehicle'] == "false" ? false : true,
                                 :logistics_company_id => params[:ba]['logistics_company_id']
                                )

          params[:services][service][:vehicles].each do |vehicle|
            @vehicle_rate = BaVehicleRate.create(:ba_service_id => @service.id,
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
                @zone_rate = BaZoneRate.create(:ba_vehicle_rate_id => @vehicle_rate.id,
                                             :name => params[:services][service][:vehicles][vehicle][:zones][zone]['name'],
                                             :rate => params[:services][service][:vehicles][vehicle][:zones][zone]['rate'],
                                             :guard_rate => params[:services][service][:vehicles][vehicle][:zones][zone]['guard_rate']
                                            )
              end
            end
            if !params[:services][service][:vehicles][vehicle][:package_rate].blank?              
              @package_rate = BaPackageRate.create(:ba_vehicle_rate_id => @vehicle_rate.id,
                                           :duration => params[:services][service][:vehicles][vehicle][:package_rate]['duration'],
                                           :package_duty_hours => params[:services][service][:vehicles][vehicle][:package_rate]['package_duty_hours'],
                                           :package_km => params[:services][service][:vehicles][vehicle][:package_rate]['package_km'],
                                           :package_overage_per_km => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_per_km'],
                                           :package_overage_per_time => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_per_time'],
                                           :package_overage_time => params[:services][service][:vehicles][vehicle][:package_rate]['package_overage_time'],
                                           :package_rate => params[:services][service][:vehicles][vehicle][:package_rate]['package_rate']
                                          )
            end
          end
        end      
      end      

      # if @business_associate.save
      #   flash[:notice] = 'Business Associate was successfully created'
      # else
      #   flash[:error] = @business_associate.errors.full_messages.to_sentence
      # end
    else
      flash[:error] = 'You have not permissions for create business associate'
    end
    # redirect_to provisioning_path(anchor: 'business-associates')
  end

  def destroy
    if current_user.admin? || current_user.operator?
      @business_associate.destroy
      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end

  private
  def set_b_a
    @business_associate = BusinessAssociate.find_by_prefix(params[:id])
  end

  def ba_params
    params.require(:business_associate).permit(
        :id, :admin_f_name, :admin_m_name, :admin_l_name, :name,
        :admin_email, :admin_phone, :legal_name, :pan, :tan,
        :business_type, :service_tax_no, :hq_address,
        :standard_price, :pay_period, :time_on_duty_limit, :distance_limit, :rate_by_time, :service_tax_percent,
        :rate_by_distance, :agreement_date, :swachh_bharat_cess, :krishi_kalyan_cess, :profit_centre, :invoice_frequency
    )
  end

end
