class Billing::CompletedVehiclesDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, user)
    @view = view
    @user = user
  end

  def as_json(options = {})
    count = get_vehicles.length
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data,
        user: @user,
        vehicles: @completed_vehicles,
        trips: @trips_vehicles
    }
  end

  private

  def data
    all_vehicles.map { |vehicle| Billing::CompletedVehicleDatatable.new(vehicle).data }
  end

  def all_vehicles
    @vehicle = Kaminari.paginate_array(get_vehicles).page(page).per(per_page)
  end

  def get_vehicles
    @trips = nil
    @completed_vehicles = {}
    @trips_vehicles = {}
    @completed_vehicles_array = []
    if params[:invoice_type] == 'customer'
      @trips = Trip.where(:status => ['completed', 'canceled'], :scheduled_date => filter_params['startDate']..filter_params['endDate']).where(:paid => 0).where('trips.cancel_status != ? or trips.cancel_status IS NULL', 'Driver Didn’t Complete').order(scheduled_date: :desc)
    else
      @trips = Trip.where(:status => ['completed', 'canceled'], :scheduled_date => filter_params['startDate']..filter_params['endDate']).where(:ba_paid => 0).where('trips.cancel_status != ? or trips.cancel_status IS NULL', 'Driver Didn’t Complete').order(scheduled_date: :desc)
    end    
    if params[:invoice_type] == 'customer'
      @trips.each do |trip|        
        # service_type = 'Door To Door'
        # if trip.bus_rider == 1
        #   service_type = 'Nodal'
        # end
        # service = Service.where(:site_id => trip.site_id).where(:logistics_company_id => trip&.driver&.logistics_company_id).where(:service_type => service_type).where(:billing_model => 'Package Rates')
        service = Service.where(:site_id => trip.site_id).where(:logistics_company_id => trip&.driver&.logistics_company_id).where(:billing_model => 'Package Rates').first
        unless service.nil? or service.blank?
          @trips_vehicles[trip.id] = trip&.vehicle_id
          if @completed_vehicles.has_key? trip&.vehicle_id
            @completed_vehicles[trip&.vehicle_id].push(trip)
          else
            @completed_vehicles[trip&.vehicle_id] = [trip]
          end
        end
      end
    else
      @trips.each do |trip|
        # service_type = 'Door To Door'
        # if trip.bus_rider == 1
        #   service_type = 'Nodal'
        # end
        # service = BaService.where(:business_associate_id => trip&.driver&.business_associate_id).where(:logistics_company_id => trip&.driver&.logistics_company_id).where(:service_type => service_type).where.not(:billing_model => 'Package Rates')
        service = BaService.where(:business_associate_id => trip&.driver&.business_associate_id).where(:logistics_company_id => trip&.driver&.logistics_company_id).where(:billing_model => 'Package Rates').first
        unless service.nil? or service.blank?
          @trips_vehicles[trip.id] = trip&.vehicle_id
          if @completed_vehicles.has_key? trip&.vehicle_id
            @completed_vehicles[trip&.vehicle_id].push(trip)            
          else
            @completed_vehicles[trip&.vehicle_id] = [trip]
          end
        end 
      end
    end
    @completed_vehicles.each do |key, value|
      trip = value&.first
      trip_ids = value.map {|t| t.id}
      hours_on_trips = value.to_a.sum { |e| e.real_duration.to_i }
      mileage_on_trips = value.to_a.sum { |e| e.actual_mileage.to_i }
      @vehicle = {
        'vehicle_id': key,
        'period': filter_params['startDate'].strftime("%m/%d/%Y %H:%M").to_s + ' to ' + filter_params['endDate'].strftime("%m/%d/%Y %H:%M").to_s,
        'customer': trip&.site&.employee_company&.name,
        'site': trip&.site&.name,
        'operator': trip&.driver&.logistics_company&.name,
        'business_associate': trip&.driver&.business_associate&.legal_name,
        'vehicle_number': trip&.vehicle&.plate_number,
        'vehicle_type': trip&.vehicle&.seats,
        'hours_on_duty': ((hours_on_trips / 60).to_i).to_s + 'h ' + (hours_on_trips % 60).to_s + 'min',
        'mileage_on_duty': mileage_on_trips,
        'total_trips': value.size,
        'hours_on_trips': ((hours_on_trips / 60).to_i).to_s + 'h ' + (hours_on_trips % 60).to_s + 'min',
        'mileage_on_trips': mileage_on_trips,
        'trips': trip_ids
      }
      @completed_vehicles_array.push(@vehicle)
    end
    @completed_vehicles_array
  end

  # get data from filter
  def filter_params
    today = Time.zone.now.beginning_of_day.in_time_zone('UTC')
    startdate = params['startDate'].blank? ? (today - 1.month) : Time.zone.parse(params['startDate'] + " IST").in_time_zone('UTC')
    endDate = params['endDate'].blank? ? today : Time.zone.parse(params['endDate'] + " IST").in_time_zone('UTC')
    {
        'startDate' => startdate,
        'endDate'=> endDate
    }
  end

end
