class Billing::CompletedTripsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, user)
    @view = view
    @user = user
  end

  def as_json(options = {})
    count = get_trips.length
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: count,
        iTotalDisplayRecords: count,
        aaData: data,
        user: @user
    }
  end

  private

  def data
    all_trips.map { |trip| Billing::CompletedTripDatatable.new(trip).data }
  end

  def all_trips
    @trip ||= Kaminari.paginate_array(get_trips).page(page).per(per_page)
  end

  def get_trips
    @trips = nil
    @completed_trips = []
    if params[:invoice_type] == 'customer'
      @trips = Trip.eager_load(:employee_trips).where('trips.status' => ['completed', 'canceled'], 'employee_trips.date' => filter_params['startDate']..filter_params['endDate']).where('trips.paid' => 0).where('trips.cancel_status != ? or trips.cancel_status IS NULL', 'Driver Didn’t Complete').order('employee_trips.date desc').except(:includes)
    else
      @trips = Trip.eager_load(:employee_trips).where('trips.status' => ['completed', 'canceled'], 'employee_trips.date' => filter_params['startDate']..filter_params['endDate']).where('trips.ba_paid' => 0).where('trips.cancel_status != ? or trips.cancel_status IS NULL', 'Driver Didn’t Complete').order('employee_trips.date desc').except(:includes)
    end
    if params[:invoice_type] == 'customer'
      @trips.each do |trip|
        # service_type = 'Door To Door'
        # if trip.bus_rider == 1
        #   service_type = 'Nodal'
        # end
        # service = Service.where(:site_id => trip.site_id).where(:logistics_company_id => trip&.driver&.logistics_company_id).where(:service_type => service_type).where.not(:billing_model => 'Package Rates')
        service = Service.where(:site_id => trip.site_id).where(:logistics_company_id => trip&.driver&.logistics_company_id).where.not(:billing_model => 'Package Rates')
        unless service.nil? or service.blank?
          @completed_trips.push(trip)
        end
      end
    else
      @trips.each do |trip|
        # service_type = 'Door To Door'
        # if trip.bus_rider == 1
        #   service_type = 'Nodal'
        # end
        # service = BaService.where(:business_associate_id => trip&.driver&.business_associate_id).where(:logistics_company_id => trip&.driver&.logistics_company_id).where(:service_type => service_type).where.not(:billing_model => 'Package Rates')
          service = BaService.where(:business_associate_id => trip&.driver&.business_associate_id).where(:logistics_company_id => trip&.driver&.logistics_company_id).where.not(:billing_model => 'Package Rates')
        unless service.nil?
          @completed_trips.push(trip)
        end 
      end
    end
    @completed_trips
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
