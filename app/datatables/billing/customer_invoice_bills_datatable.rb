class Billing::CustomerInvoiceBillsDatatable
  include DatatablePagination
  delegate :params, to: :@view

  def initialize(view, invoice = nil)
    @view = view
    @invoice = invoice
    @all_data = nil
    @billing_model = nil
  end

  def as_json(options = {})
    @all_data = get_trip_invoices
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: @all_data['count'],
        iTotalDisplayRecords: @all_data['count'],
        aaData: data,
        billing_model: @billing_model
    }
  end

  private

  def data
    @all_data['vehicle_mapping'].map { |data_item| Billing::CustomerInvoiceBillDatatable.new(data_item).data}    
    # @trip_invoices.map { |trip_invoice| Billing::CustomerInvoiceBillDatatable.new(trip_invoice).data }
  end

  def get_trip_invoices
    @trip_invoices = TripInvoice.where(:invoice_id => @invoice.id)
    vehicle_mapping = {}
    count = 0
    @trip_invoices.each do |trip_invoice|
      if !trip_invoice.trip_id.nil?        
        plate_number = trip_invoice&.trip&.vehicle&.plate_number
        vehicle_type = trip_invoice&.trip&.vehicle&.model
        zone_name = trip_invoice&.zone_rate&.name
        site = trip_invoice&.trip&.site&.name
        customer = trip_invoice&.trip&.site&.employee_company&.name
        operator = trip_invoice&.trip&.driver&.logistics_company&.name
        business_associate = trip_invoice&.trip&.driver&.business_associate&.legal_name
        is_guard = 0

        if trip_invoice&.trip&.trip_type == 0
          is_guard = trip_invoice&.trip.employee_trips.first.employee.is_guard
        else
          is_guard = trip_invoice&.trip.employee_trips.last.employee.is_guard
        end
        count = count + 1
        if plate_number.blank?
          plate_number = 'No Vehicle'
        end
        if zone_name.blank?
          zone_name = 'No Zone'
        end
        if vehicle_mapping[plate_number + '-' + zone_name].blank?
          vehicle_mapping[plate_number + '-' + zone_name] = {
            'customer' => customer,
            'site' => site,
            'operator' => operator,
            'business_associate' => business_associate,
            'plate_number' => plate_number,
            'vehicle_type' => vehicle_type,
            'zone_name' => zone_name,
            'total_trips' => 1,            
            'rate' => trip_invoice.zone_rate.rate,
            'guard_rate' => trip_invoice.zone_rate.guard_rate,
            'hours_on_duty' => 0,
            'mileage_on_duty' => 0,
            'hours_on_trips' => 0,
            'mileage_on_trips' => 0,
            'toll' => trip_invoice.trip_toll,
            'amount' => trip_invoice.trip_amount       
          }
          if is_guard == 0
            vehicle_mapping[plate_number + '-' + zone_name]['guard_trips'] = 0
          else
            vehicle_mapping[plate_number + '-' + zone_name]['guard_trips'] = 1
          end
        else
          vehicle_mapping[plate_number + '-' + zone_name] = {   
            'customer' => customer,
            'site' => site,
            'operator' => operator,
            'business_associate' => business_associate,            
            'plate_number' => plate_number,
            'vehicle_type' => vehicle_type,
            'zone_name' => zone_name,
            'total_trips' => vehicle_mapping[plate_number + '-' + zone_name]['total_trips'] + 1,
            'guard_trips' => vehicle_mapping[plate_number + '-' + zone_name]['guard_trips'],
            'rate' => vehicle_mapping[plate_number + '-' + zone_name]['rate'] + trip_invoice.zone_rate.rate,
            'guard_rate' => vehicle_mapping[plate_number + '-' + zone_name]['guard_rate'] + trip_invoice.zone_rate.guard_rate,
            'hours_on_duty' => 0,
            'mileage_on_duty' => 0,
            'hours_on_trips' => 0,
            'mileage_on_trips' => 0,
            'toll' => vehicle_mapping[plate_number + '-' + zone_name]['toll'] + trip_invoice.trip_toll,
            'amount' => vehicle_mapping[plate_number + '-' + zone_name]['amount'] + trip_invoice.trip_amount
          }
          if is_guard == 1
            vehicle_mapping[plate_number + '-' + zone_name]['guard_trips'] = vehicle_mapping[plate_number + '-' + zone_name]['guard_trips'] + 1
          end
        end
      #it is a package rate invoice
      else
        @billing_model = 'Package Rates'
        plate_number = trip_invoice&.vehicle&.plate_number
        vehicle_type = trip_invoice&.vehicle&.model
        zone_name = trip_invoice&.zone_rate&.name
        trips = VehicleTripInvoice.where(:vehicle_id => trip_invoice.vehicle_id).where(:trip_invoice_id => trip_invoice.id)
        site = trips&.first&.trip&.site&.name
        customer = trips&.first&.trip&.site&.employee_company&.name
        operator = trips&.first&.trip&.driver&.logistics_company&.name
        business_associate = trip_invoice&.vehicle&.business_associate&.legal_name
        total_trips = trips.size        
        hours_on_duty = trips.to_a.sum { |e| e.trip.real_duration.to_i }
        mileage_on_duty = trips.to_a.sum { |e| e.trip.actual_mileage.to_i }
        hours_on_trips = trips.to_a.sum { |e| e.trip.real_duration.to_i }
        mileage_on_trips = trips.to_a.sum { |e| e.trip.actual_mileage.to_i }

        is_guard = 0

        count = count + 1
        if plate_number.blank?
          plate_number = 'No Vehicle'
        end
        if vehicle_mapping[plate_number].blank?
          vehicle_mapping[plate_number] = {
            'customer' => customer,
            'site' => site,
            'operator' => operator,
            'business_associate' => business_associate,            
            'plate_number' => plate_number,
            'vehicle_type' => vehicle_type,
            'zone_name' => zone_name,
            'total_trips' => total_trips,
            'guard_trips' => 0,            
            'rate' => 0,
            'guard_rate' => 0,
            'hours_on_duty' => hours_on_duty,
            'mileage_on_duty' => mileage_on_duty,
            'hours_on_trips' => hours_on_trips,
            'mileage_on_trips' => mileage_on_trips,
            'toll' => trip_invoice.trip_toll,
            'amount' => trip_invoice.trip_amount
          }          
        else
          vehicle_mapping[plate_number] = {
            'customer' => customer,
            'site' => site,
            'operator' => operator,
            'business_associate' => business_associate,            
            'plate_number' => plate_number,
            'vehicle_type' => vehicle_type,
            'zone_name' => zone_name,
            'total_trips' => vehicle_mapping[plate_number]['total_trips'] + total_trips,
            'guard_trips' => 0,            
            'rate' => 0,
            'guard_rate' => 0,
            'hours_on_duty' => vehicle_mapping[plate_number]['hours_on_duty'] + hours_on_duty,
            'mileage_on_duty' => vehicle_mapping[plate_number]['mileage_on_duty'] + mileage_on_duty,
            'hours_on_trips' => vehicle_mapping[plate_number]['hours_on_trips'] + hours_on_trips,
            'mileage_on_trips' => vehicle_mapping[plate_number]['mileage_on_trips'] + mileage_on_trips,
            'toll' => trip_invoice.trip_toll,
            'amount' => trip_invoice.trip_amount            
          }          
        end
      end      
    end
    {
      'vehicle_mapping' => vehicle_mapping,
      'count' => count
    }
  end

end
