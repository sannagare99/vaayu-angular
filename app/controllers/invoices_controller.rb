class InvoicesController < ApplicationController 

  def index
    respond_to do |format|
      format.html
      format.json { render json: InvoicesDatatable.new(view_context, current_user)}
    end
  end

  def download
    selected = params[:selected]
    @invoice_ids = selected.split(",")
    @invoices = Invoice.find(@invoice_ids)
    package = nil
    @files = []
    @invoices.each do |invoice_id|
      invoice = Invoice.find(invoice_id)
      company = EmployeeCompany.find(invoice.company_id)
      package = Invoices::Files::Xls.new(company, nil, nil, invoice, 'customer', view_context, current_user).build()
      @files << package
    end

    @files.each_with_index do |file, index|
      file.serialize "Invoice-#{@invoice_ids[index]}.xlsx"
    end

    @filename = 'Invoices-' + Time.now().strftime("%d-%m-%Y").to_s() + '.zip'
    temp = Tempfile.new('Invoices-' + Time.now().strftime("%d-%m-%Y").to_s() + '.zip')
    begin
      Zip::OutputStream.open(temp) { |zos| }
      Zip::File.open(temp.path, Zip::File::CREATE) do |zipfile|
        
        @files.each_with_index do |file, index|
          zipfile.add "Invoice-#{@invoice_ids[index]}.xlsx", "#{Rails.root}/Invoice-#{@invoice_ids[index]}.xlsx"
        end
      end

      @files.each_with_index do |file, index|
        File.delete "Invoice-#{@invoice_ids[index]}.xlsx"
      end
      
      zip_data = File.read(temp.path)
      send_data zip_data, type: 'application/zip', filename: 'Invoices-' + Time.now().strftime("%d-%m-%Y").to_s() + '.zip'
    rescue Errno::ENOENT, IOError => e
      Rails.logger.error e.message
      temp.close
    ensure
      #Close and delete the temp file
      temp.close
      temp.unlink
    end
  end

  def ba_download
    selected = params[:selected]
    @invoice_ids = selected.split(",")
    @invoices = BaInvoice.find(@invoice_ids)
    package = nil
    @files = []
    @invoices.each do |invoice_id|
      invoice = BaInvoice.find(invoice_id)
      company = EmployeeCompany.find(invoice.company_id)
      package = Invoices::Files::Xls.new(company, nil, nil, invoice, 'ba', view_context, current_user).build()
      @files << package
    end

    @files.each_with_index do |file, index|
      file.serialize "BaInvoice-#{@invoice_ids[index]}.xlsx"
    end

    @filename = 'BaInvoices-' + Time.now().strftime("%d-%m-%Y").to_s() + '.zip'
    temp = Tempfile.new('BaInvoices-' + Time.now().strftime("%d-%m-%Y").to_s() + '.zip')
    begin
      Zip::OutputStream.open(temp) { |zos| }
      Zip::File.open(temp.path, Zip::File::CREATE) do |zipfile|
        
        @files.each_with_index do |file, index|
          zipfile.add "BaInvoice-#{@invoice_ids[index]}.xlsx", "#{Rails.root}/BaInvoice-#{@invoice_ids[index]}.xlsx"
        end
      end

      @files.each_with_index do |file, index|
        File.delete "BaInvoice-#{@invoice_ids[index]}.xlsx"
      end
      
      zip_data = File.read(temp.path)
      send_data zip_data, type: 'application/zip', filename: 'BaInvoices-' + Time.now().strftime("%d-%m-%Y").to_s() + '.zip'
    rescue Errno::ENOENT, IOError => e
      Rails.logger.error e.message
      temp.close
    ensure
      #Close and delete the temp file
      temp.close
      temp.unlink
    end
  end


  # mark invoice as paid
  def update_status
    invoice = Invoice.find(params[:id])
    status = params[:status]

    # TODO: check permission
    if status == 'created' 
      invoice.new!
      render json: {
        'success': true
      }
    elsif status == 'approved'
      invoice.approve!
      render json: {
        'success': true
      }
    elsif status == 'dirty'
      invoice.dirty!
      render json: {
        'success': true
      }
    elsif status == 'paid'
      invoice.pay!
      render json: {
        'success': true
      }
    else
      render json: {
        'success': false
      }
    end
  end

  def ba_update_status
    invoice = BaInvoice.find(params[:id])
    status = params[:status]

    # TODO: check permission
    if status == 'created' 
      invoice.new!
      render json: {
        'success': true
      }
    elsif status == 'approved'
      invoice.approve!
      render json: {
        'success': true
      }
    elsif status == 'dirty'
      invoice.dirty!
      render json: {
        'success': true
      }
    elsif status == 'paid'
      invoice.pay!
      render json: {
        'success': true
      }
    else
      render json: {
        'success': false
      }
    end
  end

  def completed_trips
    render json: Billing::CompletedTripsDatatable.new(view_context, current_user)
  end

  def completed_vehicles
    render json: Billing::CompletedVehiclesDatatable.new(view_context, current_user)
  end

  def customer_invoices
    render json: Billing::CustomerInvoicesDatatable.new(view_context, current_user)
  end

  def ba_invoices
    render json: Billing::BaInvoicesDatatable.new(view_context, current_user)
  end

  def detail_invoice
    @trip = Trip.find(params[:id])
  end

  def invoice_details
    render json: Billing::CustomerInvoiceDetailsDatatable.new(view_context)
  end

  def ba_invoice_details
    render json: Billing::BaInvoiceDetailsDatatable.new(view_context)
  end

  def trip_data
    render json: Billing::CustomerInvoiceTripsDatatable.new(view_context, Invoice.find(params[:invoice_id]))
  end

  def ba_trip_data
    render json: Billing::BaInvoiceTripsDatatable.new(view_context, BaInvoice.find(params[:invoice_id]))
  end

  def bill_data
    render json: Billing::CustomerInvoiceBillsDatatable.new(view_context, Invoice.find(params[:invoice_id]))
  end

  def ba_bill_data
    render json: Billing::BaInvoiceBillsDatatable.new(view_context, BaInvoice.find(params[:invoice_id]))
  end

  def delete_customer_invoices    
    @invoice_ids = params[:invoices]    
    trip_invoices = TripInvoice.where(:invoice_id => @invoice_ids)
    trip_invoices.each do |trip_invoice|
      Trip.where(:id => trip_invoice.trip_id).update_all({:paid => 0})
      vehicle_invoices = VehicleTripInvoice.where(:trip_invoice_id => trip_invoice.id)
      vehicle_invoices.each do |vehicle_invoice|
        Trip.where(:id => vehicle_invoice.trip_id).update_all({:paid => 0})
        vehicle_invoice.destroy
      end      
    end

    Invoice.destroy(@invoice_ids)
  end

  def delete_ba_invoices
    @invoice_ids = params[:invoices]    

    trip_invoices = TripInvoice.where(:ba_invoice_id => @invoice_ids)
    trip_invoices.each do |trip_invoice|
      Trip.where(:id => trip_invoice.trip_id).update_all({:ba_paid => 0})
      vehicle_invoices = VehicleTripInvoice.where(:ba_trip_invoice_id => trip_invoice.id)
      vehicle_invoices.each do |vehicle_invoice|
        Trip.where(:id => vehicle_invoice.trip_id).update_all({:ba_paid => 0})
        vehicle_invoice.destroy
      end      
    end

    BaInvoice.destroy(@invoice_ids)
  end

  #generate invoice
  def generate_invoices
    
  end

  def generate_invoice_for_trips
    @vehicles = JSON.parse(params[:vehicles])
    @trips_vehicles = JSON.parse(params[:trips_vehicles])
    generated_for_trips = []
    billing_model = ['Package Rates']
    total_invoices = 0
    total_records = 0
    @bad_trip_reason = ''
    if params[:billable_entity] == 'trips'
      billing_model = ['Fixed Rate per Trip', 'Fixed Rate per Zone']
    end
    #CUSTOMER INVOICES
    if params[:invoice_type] == 'customer'
      @bad_trips_customer = []
      if params[:select_all] == 'true'
        @trips = Trip.eager_load(:driver, :employee_trips).where('trips.status' => ['completed', 'canceled'], 'employee_trips.date' => filter_params['startDate']..filter_params['endDate'], 'trips.paid' => 0).where.not('trips.cancel_status' => 'Driver Didn’t Complete').except(:includes).group_by(&:trip_site)
      else
        @trips = Trip.joins(:driver).where(:id => params[:trips], :paid => 0).group_by(&:trip_site)
      end

      @trips.each do |trips_by_site| 
        @invoice = nil         
        trips_by_site.last.each do |trip|
          total_records = total_records + 1
          if trip.cancel_status != 'Driver Didn’t Complete'
            @service = nil
            if trip.bus_rider == 1
              @service = Service.where(:site => trip.site_id, :service_type => 'Nodal', :logistics_company_id => trip&.driver&.logistics_company_id, :billing_model => billing_model).first
            else
              @service = Service.where(:site => trip.site_id, :service_type => 'Door To Door', :logistics_company_id => trip&.driver&.logistics_company_id, :billing_model => billing_model).first
            end
            if(@service.nil?)
              @bad_trips_customer.push(trip.id)
              @bad_trip_reason = 'Service not configured'
            else              
              bill_amount = {}
              if params[:billable_entity] == 'trips'
                bill_amount = generate_invoice_for_trip(trip, @service)
                if bill_amount.blank?
                  @bad_trips_customer.push(trip.id)
                  @bad_trip_reason = 'Rates not configured for vehicle/trip'
                else
                  if (@invoice.nil?)
                    @invoice = Invoice.create!(:company_id => trips_by_site.first.employee_company.id,
                              :date => Time.now())
                    total_invoices = total_invoices + 1     
                  end
                  @trip_invoice = create_trip_invoices(trip, bill_amount, @invoice)
                end
              else
                if !generated_for_trips.include? trip.id
                  bill_amount = generate_invoice_for_vehicle(@vehicles, @trips_vehicles, trip, @service, generated_for_trips, @bad_trips_customer)
                  bill_amount = calculate_package_amount(bill_amount, 'customer')
                  if (@invoice.nil?)
                    @invoice = Invoice.create!(:company_id => trips_by_site.first.employee_company.id,
                              :date => Time.now())
                    total_invoices = total_invoices + 1
                  end
                  create_vehicle_invoice(@vehicles, trip, bill_amount, @invoice)
                end
              end              
            end
          end        
        end
      end
    #BA INVOICES  
    else
      @bad_trips_ba = []
      ba_mapping = {}
      if params[:select_all] == 'true'
        @ba_trips = Trip.eager_load(:driver, :employee_trips).where('trips.status' => ['completed', 'canceled'], 'employee_trips.date' => filter_params['startDate']..filter_params['endDate'], 'trips.ba_paid' => 0).where.not('trips.cancel_status' => 'Driver Didn’t Complete').except(:includes).group_by(&:trip_site)
      else
        @ba_trips = Trip.joins(:driver).where(:id => params[:trips], :ba_paid => 0).group_by(&:trip_site)
      end
      @ba_trips.each do |trips_by_site|
        trips_by_site.last.each do |trip|
          if ba_mapping.has_key? trip&.driver&.business_associate&.id
            ba_mapping[trip&.driver&.business_associate&.id] << trip
          else
            ba_mapping[trip&.driver&.business_associate&.id] = []
            ba_mapping[trip&.driver&.business_associate&.id] << trip
          end
        end
      end    
      ba_mapping.each {|ba_id, trips|
        @ba_invoice = nil        
        trips.each do |trip|
          total_records = total_records + 1
          if trip.cancel_status != 'Driver Didn’t Complete'
            @service = nil
            if trip.bus_rider == 1
              @service = BaService.where(:business_associate_id => ba_id, :service_type => 'Nodal', :logistics_company_id => trip&.driver&.logistics_company_id, :billing_model => billing_model).first
            else
              @service = BaService.where(:business_associate_id => ba_id, :service_type => 'Door To Door', :logistics_company_id => trip&.driver&.logistics_company_id, :billing_model => billing_model).first
            end


            if(@service.nil?)
              @bad_trips_ba.push(trip.id)
              @bad_trip_reason = 'Service not configured'
            else            
              bill_amount = {}
              if params[:billable_entity] == 'trips'
                bill_amount = generate_ba_invoice_for_trip(trip, @service)
                if bill_amount.blank?
                  @bad_trips_ba.push(trip.id)
                  @bad_trip_reason = 'Rates not configured for vehicle/trip'
                else
                  if (@invoice.nil?)                
                    @ba_invoice = BaInvoice.create!(:company_id => trips.first.site.employee_company.id,
                              :date => Time.now())
                    total_invoices = total_invoices + 1
                  end
                  @ba_trip_invoice = create_ba_trip_invoices(trip, bill_amount, @ba_invoice)
                end
              else
                if !generated_for_trips.include? trip.id
                  bill_amount = generate_ba_invoice_for_vehicle(@vehicles, @trips_vehicles, trip, @service, generated_for_trips, @bad_trips_customer)
                  bill_amount = calculate_package_amount(bill_amount, 'ba')
                  create_ba_vehicle_invoice(@vehicles, trip, bill_amount, @ba_invoice)                  
                end
              end              
            end            
          end        
        end
      }
    end    
    #RETURN
    render json: {
      'bad_trips_customer': @bad_trips_customer,
      'bad_trips_ba': @bad_trips_ba,
      'total_invoices': total_invoices,
      'total_records': total_records,
      'bad_trip_reason': @bad_trip_reason
    } 
  end

  def create_trip_invoices(trip, bill_amount, invoice)
    Trip.where(:id => trip.id).update_all({:toll=>bill_amount['toll'], :penalty => bill_amount['penalty'], :amount => bill_amount['amount'], :paid => 1})
    @trip_invoice = TripInvoice.create!(:invoice_id => invoice.id, 
                        :trip_id => trip.id,
                        :trip_amount => bill_amount['amount'],
                        :trip_penalty => bill_amount['penalty'],
                        :trip_toll => bill_amount['toll'],
                        :vehicle_rate_id => bill_amount['vehicle_rate_id'],
                        :zone_rate_id => bill_amount['zone_rate_id'],
                        :package_rate_id => bill_amount['package_rate_id']
                      )
    @trip_invoice.id
  end

  def create_ba_trip_invoices(trip, bill_amount, invoice)
    Trip.where(:id => trip.id).update_all({:ba_toll=>bill_amount['toll'], :ba_penalty => bill_amount['penalty'], :ba_amount => bill_amount['amount'], :ba_paid => 1})
    @ba_trip_invoice = BaTripInvoice.create!(:ba_invoice_id => invoice.id, 
                      :trip_id => trip.id,
                      :trip_amount => bill_amount['amount'],
                      :trip_penalty => bill_amount['penalty'],
                      :trip_toll => bill_amount['toll'],
                      :ba_vehicle_rate_id => bill_amount['vehicle_rate_id'],
                      :ba_zone_rate_id => bill_amount['zone_rate_id'],
                      :ba_package_rate_id => bill_amount['package_rate_id']
                    )
    @ba_trip_invoice.id
  end  

  def create_vehicle_invoice(vehicles, trip, bill_amount, invoice)
    all_trips = vehicles[trip.vehicle_id.to_s]
    @trip_invoice = TripInvoice.create!(:invoice_id => invoice.id, 
                        :vehicle_id => trip&.vehicle_id,
                        :trip_amount => bill_amount['amount'],
                        :trip_penalty => bill_amount['penalty'],
                        :trip_toll => bill_amount['toll'],
                        :vehicle_rate_id => bill_amount['vehicle_rate_id'],
                        :package_rate_id => bill_amount['package_rate_id']
                      )    
    all_trips.each do |t|
      Trip.where(:id => t["id"]).update_all({:toll=>bill_amount['toll'], :penalty => bill_amount["penalty"], :amount => bill_amount["amount"], :paid => 1})
      VehicleTripInvoice.create!(:trip_id => t["id"],
                                 :vehicle_id => t["vehicle_id"],
                                 :trip_invoice_id => @trip_invoice.id 
                                )
    end
  end

  def create_ba_vehicle_invoice(vehicles, trip, bill_amount, invoice)
    all_trips = vehicles[trip.vehicle_id.to_s]
    @trip_invoice = BaTripInvoice.create!(:ba_invoice_id => invoice.id, 
                        :vehicle_id => trip&.vehicle_id,
                        :trip_amount => bill_amount['amount'],
                        :trip_penalty => bill_amount['penalty'],
                        :trip_toll => bill_amount['toll'],
                        :ba_vehicle_rate_id => bill_amount['vehicle_rate_id'],
                        :ba_package_rate_id => bill_amount['package_rate_id']
                      )    
    all_trips.each do |t|
      Trip.where(:id => t["id"]).update_all({:ba_toll=>bill_amount['toll'], :ba_penalty => bill_amount["penalty"], :ba_amount => bill_amount["amount"], :ba_paid => 1})
      VehicleTripInvoice.create!(:trip_id => t["id"],
                                 :vehicle_id => t["vehicle_id"],
                                 :ba_trip_invoice_id => @trip_invoice.id 
                                )
    end
  end

  def generate_invoice_for_vehicle(vehicles, trips_vehicles, trip, service, generated_for_trips, bad_trips_customer)
    all_trips = vehicles[trip.vehicle_id.to_s]
    bill_amount = {
      'amount' => 0,
      'penalty' => 0,
      'toll' => 0,
      'package_mileage' => 0,
      'actual_mileage' => 0,
      'package_duty_hours' => 0,
      'actual_duty_hours' => 0,
      'real_duration' => 0
    }
    all_trips.each do |t|
      generated_for_trips.push(t["id"])
      if service.vary_with_vehicle
        puts "********** case Package - vehicle ***********"
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => vehicle.seats).where(:ac => vehicle.ac).first        
      else
        puts "********** case Package - NO vehicle ***********"
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => 0).first
      end
      if !vehicle_rate.blank?
        package_rate = PackageRate.where(:vehicle_rate_id => vehicle_rate.id).first
        bill_amount['vehicle_rate_id'] = vehicle_rate.id
        bill_amount['package_rate_id'] = package_rate.id
        if t["actual_mileage"].nil?
          bill_amount['actual_mileage'] += 0
        else
          bill_amount['actual_mileage'] += t["actual_mileage"]
        end
        
        if t["real_duration"].nil?
          bill_amount['real_duration'] += 0
        else
          bill_amount['real_duration'] += t["real_duration"]
        end
        
        duty_hours = DriversShift.where(:vehicle_id => t["vehicle_id"], :driver_id => t["driver_id"]).where("start_time <= ? AND ? < end_time", t["start_date"], t["start_date"]).first&.duration
        if duty_hours.nil?
          bill_amount['actual_duty_hours'] += 0
        else
          bill_amount['actual_duty_hours'] += duty_hours  
        end
      else
        bad_trips_customer.push(t.id)
      end
    end
    bill_amount
  end

  def generate_ba_invoice_for_vehicle(vehicles, trips_vehicles, trip, service, generated_for_trips, bad_trips_customer)
    all_trips = vehicles[trip.vehicle_id.to_s]
    bill_amount = {
      'amount' => 0,
      'penalty' => 0,
      'toll' => 0,
      'package_mileage' => 0,
      'actual_mileage' => 0,
      'package_duty_hours' => 0,
      'actual_duty_hours' => 0,
      'real_duration' => 0
    }
    all_trips.each do |t|
      generated_for_trips.push(t["id"])
      if service.vary_with_vehicle
        puts "********** case Package - vehicle ***********"
        vehicle_rate = BaVehicleRate.where(:ba_service_id => service.id).where(:vehicle_capacity => vehicle.seats).where(:ac => vehicle.ac).first        
      else
        puts "********** case Package - NO vehicle ***********"
        vehicle_rate = BaVehicleRate.where(:ba_service_id => service.id).where(:vehicle_capacity => 0).first
      end
      if !vehicle_rate.blank?
        package_rate = BaPackageRate.where(:ba_vehicle_rate_id => vehicle_rate.id).first
        bill_amount['vehicle_rate_id'] = vehicle_rate.id
        bill_amount['package_rate_id'] = package_rate.id

        if t["actual_mileage"].nil?
          bill_amount['actual_mileage'] += 0
        else
          bill_amount['actual_mileage'] += t["actual_mileage"]
        end
        
        if t["real_duration"].nil?
          bill_amount['real_duration'] += 0
        else
          bill_amount['real_duration'] += t["real_duration"]
        end

        duty_hours = DriversShift.where(:vehicle_id => t.vehicle_id, :driver_id => t.driver_id).where("start_time <= ? AND ? < end_time", t.start_date, t.start_date).first&.duration
        if duty_hours.nil?
          bill_amount['actual_duty_hours'] += 0
        else
          bill_amount['actual_duty_hours'] += duty_hours  
        end
      else
        bad_trips_customer.push(t.id)
      end
    end
    bill_amount
  end

  def calculate_package_amount(bill_amount, type)    
    package_rate = nil
    delta_km = 0
    delta_time = 0
    if type == 'customer'
      package_rate = PackageRate.find(bill_amount["package_rate_id"])
    else
      package_rate = BaPackageRate.find(bill_amount["package_rate_id"])
    end


    #TODO GET OFF TRIP MILEAGE
    if package_rate.package_mileage_calculation == 'On Duty Hours'
      if package_rate.package_km.nil?
        # delta_km will be 0
        bill_amount["package_mileage"] = 0
      else
        bill_amount["package_mileage"] = package_rate.package_km
        delta_km = bill_amount["actual_mileage"] - bill_amount["package_mileage"]
      end
      if package_rate.package_duty_hours.nil?
        # delta_time will be 0
        bill_amount["package_duty_hours"] = 0
      else
        bill_amount["package_duty_hours"] = package_rate.package_duty_hours
        delta_time = (bill_amount["actual_duty_hours"] / 60 ) - bill_amount["package_duty_hours"]
      end
    else
      if package_rate.package_km.nil?
        # delta_km will be 0
        bill_amount["package_mileage"] = 0
      else
        bill_amount["package_mileage"] = package_rate.package_km
        delta_km = bill_amount["actual_mileage"] - bill_amount["package_mileage"]
      end
      if package_rate.package_duty_hours.nil?
        # delta_time will be 0
        bill_amount["package_duty_hours"] = 0
      else
        bill_amount["package_duty_hours"] = package_rate.package_duty_hours
        delta_time = (bill_amount["actual_duty_hours"] / 60 ) - bill_amount["package_duty_hours"]
      end
    end    
        
    overage_km_amount = 0
    overage_time_amount = 0
    if delta_km > 0
      overage_km_amount = delta_km * package_rate.package_overage_per_km
    end
    if package_rate.package_overage_time
      if delta_time > 0
        overage_time_amount = delta_time * package_rate.package_overage_per_time
      end
    end
    amount = package_rate.package_rate + overage_km_amount + overage_time_amount
    bill_amount["actual_duty_hours"] = bill_amount["actual_duty_hours"] / 60
    bill_amount["amount"] = amount
    bill_amount
  end

  def generate_invoice_for_trip(trip, service)
    #TODO ignoring overage as of now
    vehicle = Vehicle.where(:id => trip.vehicle_id).first
    billing_zone = trip.employee_trips.collect {|employee_trip| employee_trip.employee[:billing_zone]}.uniq
    is_guard = 0
    vehicle_rate = nil
    zone_rate = nil
    package_rate = nil
    if trip.trip_type == 0
      is_guard = trip.employee_trips.first.employee.is_guard
    else
      is_guard = trip.employee_trips.last.employee.is_guard
    end
    if service.billing_model == 'Fixed Rate per Trip'      
      if service.vary_with_vehicle
        puts "********** case trip - vehicle ***********"
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => vehicle.seats).where(:ac => vehicle.ac).first        
      else
        puts "********** case trip - NO vehicle ***********"
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => 0).first        
      end
      if !vehicle_rate.blank?
        zone_rate = ZoneRate.where(:vehicle_rate_id => vehicle_rate.id).where(:name => 'Default').first
      else
        return {}
      end
    elsif service.billing_model == 'Fixed Rate per Zone'
      if service.vary_with_vehicle
        puts "********** case Zone - vehicle ***********"        
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => vehicle.seats).where(:ac => vehicle.ac).first        
      else
        puts "********** case zone - NO vehicle ***********"
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => 0).first
      end
      if !vehicle_rate.blank?
        zone_rate = ZoneRate.where(:vehicle_rate_id => vehicle_rate.id).where(:name => billing_zone).order(rate: :desc).first
      else
        return {}
      end
    elsif service.billing_model == 'Package Rates'
      if service.vary_with_vehicle
        puts "********** case Package - vehicle ***********"
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => vehicle.seats).where(:ac => vehicle.ac).first        
      else
        puts "********** case Package - NO vehicle ***********"
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => 0).first
      end
      if !vehicle_rate.blank?
        package_rate = PackageRate.where(:vehicle_rate_id => vehicle_rate.id).first
      else
        return {}
      end
    end
    calculate_cost(vehicle_rate, zone_rate, package_rate, is_guard)
  end

  def generate_ba_invoice_for_trip(trip, service)
    #TODO ignoring overage as of now
    vehicle = Vehicle.where(:id => trip.vehicle_id).first
    billing_zone = trip.employee_trips.collect {|employee_trip| employee_trip.employee[:billing_zone]}.uniq
    is_guard = 0
    vehicle_rate = nil
    zone_rate = nil
    package_rate = nil
    if trip.trip_type == 0
      is_guard = trip.employee_trips.first.employee.is_guard
    else
      is_guard = trip.employee_trips.last.employee.is_guard
    end
    if service.billing_model == 'Fixed Rate per Trip'      
      if service.vary_with_vehicle
        puts "********** case trip - vehicle ***********"
        vehicle_rate = BaVehicleRate.where(:ba_service_id => service.id).where(:vehicle_capacity => vehicle.seats).where(:ac => vehicle.ac).first        
      else
        puts "********** case trip - NO vehicle ***********"
        vehicle_rate = BaVehicleRate.where(:ba_service_id => service.id).where(:vehicle_capacity => 0).first        
      end
      if !vehicle_rate.blank?
        zone_rate = BaZoneRate.where(:ba_vehicle_rate_id => vehicle_rate.id).where(:name => 'Default').first
      else
        return {}
      end
    elsif service.billing_model == 'Fixed Rate per Zone'
      if service.vary_with_vehicle
        puts "********** case Zone - vehicle ***********"        
        vehicle_rate = BaVehicleRate.where(:ba_service_id => service.id).where(:vehicle_capacity => vehicle.seats).where(:ac => vehicle.ac).first        
      else
        puts "********** case zone - NO vehicle ***********"
        vehicle_rate = BaVehicleRate.where(:ba_service_id => service.id).where(:vehicle_capacity => 0).first
      end
      if !vehicle_rate.blank?
        zone_rate = BaZoneRate.where(:ba_vehicle_rate_id => vehicle_rate.id).where(:name => billing_zone).order(rate: :desc).first
      else
        return {}
      end
    elsif service.billing_model == 'Package Rates'
      if service.vary_with_vehicle
        puts "********** case Package - vehicle ***********"
        vehicle_rate = BaVehicleRate.where(:ba_service_id => service.id).where(:vehicle_capacity => vehicle.seats).where(:ac => vehicle.ac).first        
      else
        puts "********** case Package - NO vehicle ***********"
        vehicle_rate = BaVehicleRate.where(:ba_service_id => service.id).where(:vehicle_capacity => 0).first
      end
      if !vehicle_rate.blank?
        package_rate = BaPackageRate.where(:ba_vehicle_rate_id => vehicle_rate.id).first
      else
        return {}
      end
    end
    calculate_cost(vehicle_rate, zone_rate, package_rate, is_guard)
  end

  def calculate_cost(vehicle_rate, zone_rate, package_rate, is_guard)
    amount = 0
    zone_rate_id = nil
    vehicle_rate_id = nil    
    package_rate_id = nil
    # zone rate calculations
    if zone_rate.blank?
      zone_rate_id = nil
    else
      zone_rate_id = zone_rate.id
      if is_guard
        amount = zone_rate[:rate] + zone_rate[:guard_rate]
      else
        amount = zone_rate[:rate]
      end
    end
    #vehicle rate calculations
    if vehicle_rate.blank?
      vehicle_rate_id = nil
    else
      vehicle_rate_id = vehicle_rate.id
    end
    #package rate calculations
    if package_rate.blank?
      package_rate_id = nil
    else
      package_rate_id = package_rate.id
    end


    bill_amount = {
      'amount' => amount,
      'penalty' => 0,
      'toll' => 0,
      'zone_rate_id' => zone_rate_id,
      'vehicle_rate_id' => vehicle_rate_id,
      'package_rate_id' => package_rate_id
    }
  end

  # get data from filter
  def filter_params
    today = Time.zone.now.beginning_of_day.in_time_zone('UTC')
    startDate = params['startDate'].blank? ? (today - 1.month) : Time.zone.parse(params['startDate'] + " IST").in_time_zone('UTC')
    endDate = params['endDate'].blank? ? today : Time.zone.parse(params['endDate'] + " IST").in_time_zone('UTC')
    {
        'startDate' => startDate,
        'endDate'=> endDate
    }
  end

end
