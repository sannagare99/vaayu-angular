class Invoices::Files::Xls
  attr_reader :package, :filename, :company, :period, :trips, :invoice

  def initialize(company, period, trips, invoice, type, view_context = nil, user)
    @company = company
    @trips = trips
    @invoice = invoice
    @period = period
    @view_context = view_context
    @package = Axlsx::Package.new
    @type = type
    @user = user
  end

  def build
    @package.workbook do |wb|
      styles = wb.styles
      @bold_align_center = styles.add_style :sz => 12, alignment: {horizontal: :center}, :b => true, :type => :dxf
      @bold = styles.add_style :sz => 12, :b => true, :type => :dxf
      @page_title = styles.add_style :sz => 14, alignment: {horizontal: :center}
      @align_left = styles.add_style :sz => 12, alignment: {horizontal: :left}
      vehicle_rate = nil
      package_rate = nil
      if @type == 'customer'
        vehicle_rate = VehicleRate.find(TripInvoice.where(:invoice_id => @invoice.id).first&.vehicle_rate_id)
        package_rate = PackageRate.where(:vehicle_rate_id => vehicle_rate.id).first
      elsif @type == 'ba'
        vehicle_rate = BaVehicleRate.find(BaTripInvoice.where(:ba_invoice_id => @invoice.id).first&.ba_vehicle_rate_id)
        package_rate = BaPackageRate.where(:ba_vehicle_rate_id => vehicle_rate.id).first
      end
      total_amount = 0
      toll_charges = 0

      wb.add_worksheet(:name => 'TRIP DATA') do |sheet|
        trip_data = nil
        sheet = trip_data_header(package_rate, sheet)
        if @type == 'customer'
          trip_data = Billing::CustomerInvoiceTripsDatatable.new(@view_context, @invoice).as_json()
        elsif @type == 'ba'          
          trip_data = Billing::BaInvoiceTripsDatatable.new(@view_context, @invoice).as_json()
        end
          
        sheet = trip_data_content(trip_data, package_rate, sheet)
      end

      wb.add_worksheet(:name => 'BILL DATA(ANNEXURE)') do |sheet|          
        sheet = bill_data_header(package_rate, sheet)
        bill_data = nil
        if @type == 'customer'
          bill_data = Billing::CustomerInvoiceBillsDatatable.new(@view_context, @invoice).as_json()
        elsif @type == 'ba'
          bill_data = Billing::BaInvoiceBillsDatatable.new(@view_context, @invoice).as_json()
        end

        data = bill_data_content(bill_data, package_rate, sheet, total_amount, toll_charges)
        sheet = data[:sheet]
        total_amount = data[:total_amount]
        toll_charges = data[:toll_charges]
      end

      wb.add_worksheet(:name => 'INVOICE') do |sheet|
        invoice_header(sheet, @page_title, @align_left, @bold, total_amount, toll_charges, vehicle_rate.cgst, vehicle_rate.sgst)
        # sheet.add_row ['', 'Vehicle Type', '', 'Total Trips/period', 'Overage mileage rate', 'Overage time rate', 'Overages (rupees)', 'Extra mileage', 'Extra time', 'Amount'], :style => [ nil, @bold_align_center]
        sheet.add_row ['']
        # for_each_site(@trips) do |trips|
        #   for_each_vehicle(trips)
        # end
        invoice_footer(sheet)
      end
    end
    @package
    # @invoice.invoice_attachments.create(:file => @package.to_stream, :file_file_name => 'test_invoice.csv', :file_content_type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  def trip_data_header(package_rate, sheet)
    if @user.entity == 'Operator'
      if(package_rate.nil?)
        sheet.add_row ['Date', 'Customer', 'Site', 'Business Associate', 'Tripsheet #', 'Trip Type', 'Shift Time', 'Reporting Time', 'Actual Time', 'Vehicle #', 'Vehicle Type', 'Seating Capacity', 'Driver', 'Planned Employees', 'Actual Employees', 'Guard (Y/N)', 'GPS (Y/N)'], :style => [ nil, @bold_align_center]  
      else
        sheet.add_row ['Date', 'Customer', 'Site', 'Business Associate', 'Tripsheet #', 'Trip Type', 'Shift Time', 'Reporting Time', 'Actual Time', 'Vehicle #', 'Vehicle Type', 'Seating Capacity', 'Driver', 'Planned Employees', 'Actual Employees', 'Guard (Y/N)', 'GPS (Y/N)', 'Planned Mileage (in kms)', 'Planned Duration (in hours)', 'Actual Mileage (in kms)', 'Actual Duration (in hours)'], :style => [ nil, @bold_align_center]  
      end
    elsif @user.entity == 'Employer'
      if(package_rate.nil?)
        sheet.add_row ['Date', 'Site', 'Operator', 'Tripsheet #', 'Trip Type', 'Shift Time', 'Reporting Time', 'Actual Time', 'Vehicle #', 'Vehicle Type', 'Seating Capacity', 'Driver', 'Planned Employees', 'Actual Employees', 'Guard (Y/N)', 'GPS (Y/N)'], :style => [ nil, @bold_align_center]  
      else
        sheet.add_row ['Date', 'Site', 'Operator', 'Tripsheet #', 'Trip Type', 'Shift Time', 'Reporting Time', 'Actual Time', 'Vehicle #', 'Vehicle Type', 'Seating Capacity', 'Driver', 'Planned Employees', 'Actual Employees', 'Guard (Y/N)', 'GPS (Y/N)', 'Planned Mileage (in kms)', 'Planned Duration (in hours)', 'Actual Mileage (in kms)', 'Actual Duration (in hours)'], :style => [ nil, @bold_align_center]  
      end
    else
      if(package_rate.nil?)
        sheet.add_row ['Date', 'Customer', 'Site', 'Operator', 'Business Associate', 'Tripsheet #', 'Trip Type', 'Shift Time', 'Reporting Time', 'Actual Time', 'Vehicle #', 'Vehicle Type', 'Seating Capacity', 'Driver', 'Planned Employees', 'Actual Employees', 'Guard (Y/N)', 'GPS (Y/N)'], :style => [ nil, @bold_align_center]  
      else
        sheet.add_row ['Date', 'Customer', 'Site', 'Operator', 'Business Associate', 'Tripsheet #', 'Trip Type', 'Shift Time', 'Reporting Time', 'Actual Time', 'Vehicle #', 'Vehicle Type', 'Seating Capacity', 'Driver', 'Planned Employees', 'Actual Employees', 'Guard (Y/N)', 'GPS (Y/N)', 'Planned Mileage (in kms)', 'Planned Duration (in hours)', 'Actual Mileage (in kms)', 'Actual Duration (in hours)'], :style => [ nil, @bold_align_center]  
      end
    end
    sheet
  end

  def bill_data_header(package_rate, sheet)
    if @user.entity == 'Operator'
      if(package_rate.nil?)
        sheet.add_row ['Customer', 'Site', 'Business Associate', 'Vehicle #', 'Vehicle Type', 'Total Trips', 'Guard Trips', 'Amount'], :style => [ nil, @bold_align_center]  
      else
        sheet.add_row ['Customer', 'Site', 'Business Associate', 'Vehicle #', 'Vehicle Type', 'Total Trips', 'Guard Trips', 'Hours On Duty', 'Mileage On Duty (in kms)', 'Hours On Trips', 'Mileage On Trips', 'Amount'], :style => [ nil, @bold_align_center]  
      end
    elsif @user.entity == 'Employer'
      if(package_rate.nil?)
        sheet.add_row ['Site', 'Operator', 'Vehicle #', 'Vehicle Type', 'Total Trips', 'Guard Trips', 'Amount'], :style => [ nil, @bold_align_center]  
      else
        sheet.add_row ['Site', 'Operator', 'Vehicle #', 'Vehicle Type', 'Total Trips', 'Guard Trips', 'Hours On Duty', 'Mileage On Duty (in kms)', 'Hours On Trips', 'Mileage On Trips', 'Amount'], :style => [ nil, @bold_align_center]  
      end
    else
      if(package_rate.nil?)
        sheet.add_row ['Customer', 'Site', 'Operator', 'Business Associate', 'Vehicle #', 'Vehicle Type', 'Total Trips', 'Guard Trips', 'Amount'], :style => [ nil, @bold_align_center]  
      else
        sheet.add_row ['Customer', 'Site', 'Operator', 'Business Associate', 'Vehicle #', 'Vehicle Type', 'Total Trips', 'Guard Trips', 'Hours On Duty', 'Mileage On Duty (in kms)', 'Hours On Trips', 'Mileage On Trips', 'Amount'], :style => [ nil, @bold_align_center]  
      end
    end
    sheet
  end  

  def trip_data_content(trip_data, package_rate, sheet)
    trip_data[:aaData].each do |data|
      csv_string = []
      if @user.entity == 'Operator'
        if(package_rate.nil?)
          csv_string = [data[:date], data[:customer], data[:site], data[:business_associate], data[:tripsheet], data[:trip_type], data[:shift_time], data[:reporting_time], data[:actual_time], data[:vehicle_no], data[:vehicle_type], data[:seating_capacity], data[:driver], data[:planned_employees], data[:actual_employees], data[:guard], data[:gps]]
        else
          csv_string = [data[:date], data[:customer], data[:site], data[:business_associate], data[:tripsheet], data[:trip_type], data[:shift_time], data[:reporting_time], data[:actual_time], data[:vehicle_no], data[:vehicle_type], data[:seating_capacity], data[:driver], data[:planned_employees], data[:actual_employees], data[:guard], data[:gps], data[:planned_mileage], data[:planned_duration], data[:actual_mileage], data[:actual_duration]]
        end
      elsif @user.entity == 'Employer'
        if(package_rate.nil?)
          csv_string = [data[:date], data[:site], data[:operator], data[:tripsheet], data[:trip_type], data[:shift_time], data[:reporting_time], data[:actual_time], data[:vehicle_no], data[:vehicle_type], data[:seating_capacity], data[:driver], data[:planned_employees], data[:actual_employees], data[:guard], data[:gps]]
        else
          csv_string = [data[:date], data[:site], data[:operator], data[:tripsheet], data[:trip_type], data[:shift_time], data[:reporting_time], data[:actual_time], data[:vehicle_no], data[:vehicle_type], data[:seating_capacity], data[:driver], data[:planned_employees], data[:actual_employees], data[:guard], data[:gps], data[:planned_mileage], data[:planned_duration], data[:actual_mileage], data[:actual_duration]]
        end
      else
        if(package_rate.nil?)
          csv_string = [data[:date], data[:customer], data[:site], data[:operator], data[:business_associate], data[:tripsheet], data[:trip_type], data[:shift_time], data[:reporting_time], data[:actual_time], data[:vehicle_no], data[:vehicle_type], data[:seating_capacity], data[:driver], data[:planned_employees], data[:actual_employees], data[:guard], data[:gps]]
        else
          csv_string = [data[:date], data[:customer], data[:site], data[:operator], data[:business_associate], data[:tripsheet], data[:trip_type], data[:shift_time], data[:reporting_time], data[:actual_time], data[:vehicle_no], data[:vehicle_type], data[:seating_capacity], data[:driver], data[:planned_employees], data[:actual_employees], data[:guard], data[:gps], data[:planned_mileage], data[:planned_duration], data[:actual_mileage], data[:actual_duration]]
        end
      end
      sheet.add_row(csv_string)
    end
    sheet
  end

  def bill_data_content(bill_data, package_rate, sheet, total_amount, toll_charges)
    total_trips = 0
    guard_trips = 0
    bill_data[:aaData].each do |data|
      csv_string = []
      if @user.entity == 'Operator'
        if(package_rate.nil?)
          csv_string = [data[:customer], data[:site], data[:business_associate], data[:vehicle_no], data[:vehicle_type], data[:total_trips], data[:guard_trips], data[:amount]]
        else          
          csv_string = [data[:customer], data[:site], data[:business_associate], data[:vehicle_no], data[:vehicle_type], data[:total_trips], data[:guard_trips], data[:hours_on_duty], data[:mileage_on_duty], data[:hours_on_trips], data[:mileage_on_trips], data[:amount]]
        end
      elsif @user.entity == 'Employer'
        if(package_rate.nil?)
          csv_string = [data[:site], data[:operator], data[:vehicle_no], data[:vehicle_type], data[:total_trips], data[:guard_trips], data[:amount]]
        else          
          csv_string = [data[:site], data[:operator], data[:vehicle_no], data[:vehicle_type], data[:total_trips], data[:guard_trips], data[:hours_on_duty], data[:mileage_on_duty], data[:hours_on_trips], data[:mileage_on_trips], data[:amount]]
        end
      else
        if(package_rate.nil?)
          csv_string = [data[:customer], data[:site], data[:operator], data[:business_associate], data[:vehicle_no], data[:vehicle_type], data[:total_trips], data[:guard_trips], data[:amount]]
        else          
          csv_string = [data[:customer], data[:site], data[:operator], data[:business_associate], data[:vehicle_no], data[:vehicle_type], data[:total_trips], data[:guard_trips], data[:hours_on_duty], data[:mileage_on_duty], data[:hours_on_trips], data[:mileage_on_trips], data[:amount]]
        end
      end

      total_trips = total_trips + data[:total_trips]
      guard_trips = guard_trips + data[:guard_trips]
      total_amount = total_amount + data[:amount]
      toll_charges = toll_charges + data[:toll]
      sheet.add_row(csv_string)
    end
    if(package_rate.nil?)
      sheet.add_row ['Total', '', '', '', '', '', total_trips, guard_trips, total_amount], :style => [nil, @bold]
    else          
      sheet.add_row ['Total', '', '', '', '', '', total_trips, guard_trips, '', '', '', '', total_amount], :style => [nil, @bold]
    end
    {
      'sheet': sheet,
      'total_amount': total_amount,
      'toll_charges': toll_charges
    }
  end

  def invoice_header(sheet, page_title, align_left, bold, total_amount, toll_charges, cgst, sgst)
    sheet.merge_cells("B1:E1")
    sheet.add_row ['', 'INVOICE'], :style => [nil, page_title]

    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    sheet.add_row ['', 'TO']
    sheet.add_row ['', @company.logistics_company&.name.to_s, '', '', @company.logistics_company&.hq_address&.to_s == nil ? 'Address' : @company.logistics_company&.hq_address&.to_s]    
    sheet.add_row ['']
    sheet.add_row ['']    
    sheet.add_row ['']
    sheet.add_row ['']    
    sheet.add_row ['', "Customer PAN No: #{@company&.pan&.to_s}"]
    sheet.add_row ['', "Customer GSTIN: #{@company&.tan&.to_s}"]
    sheet.add_row ['']        
    sheet.add_row ['']    
    sheet.add_row ['', "Invoice No: #{@invoice.id}", '', '', "PAN No: #{@company.logistics_company&.pan&.to_s}"]
    sheet.add_row ['', "Date: #{@invoice.date&.strftime("%d/%m/%Y")}", '', '', "GSTIN: #{@company.logistics_company&.tan&.to_s}"]
    sheet.add_row ['', '', '', '', "CIN No: #{@company.logistics_company&.tan&.to_s}"]
    sheet.add_row ['', '', '', '', "Nature of Services: Rent a Cab"]
    sheet.add_row ['']        
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['', 'SR No.', 'Description - Event', 'Rate', 'Total Amount'], :style => [nil, align_left]
    sheet.add_row ['', '1', "TRANSPORTATION CHARGES FOR EMPLOYEES (AS PER ANNEXURE I ATTACHED)", '', total_amount]
    sheet.add_row ['']
    sheet.add_row ['', '2', 'TOLL CHARGES', '', toll_charges]
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['', '', 'CGST (Central Tax)', cgst, 0.01*cgst*(total_amount+toll_charges)]
    sheet.add_row ['', '', 'SGST (State Tax)', sgst, 0.01*sgst*(total_amount+toll_charges)]
    total = total_amount + toll_charges + 0.01*cgst*(total_amount+toll_charges) + 0.01*sgst*(total_amount+toll_charges)
    sheet.add_row ['', 'Total', '', '', total], :style => [nil, bold]
    sheet.add_row ['']
    rupees_words = to_words(total.to_s.split(".").first).humanize
    paise_words = to_words(total.to_s.split(".").second) == '' ? '' : ' and ' + to_words(total.to_s.split(".").second) + ' paise'
    sheet.add_row ['', 'Rupees: ' + rupees_words + paise_words + ' only'], :style => [nil, bold]
  end

  def invoice_footer(sheet)
    sheet.add_row ['']
    sheet.add_row ['', 'Terms and Conditions:'], :style => [ nil, @bold]

    sheet.add_row ['', '1     All Payments by cheques/drafts in favour of "MAHINDRA LOGISTICS LTD" should be crossed to payees account. ']
    sheet.add_row ['', '2     No claims and / or discrepancy if any shall be considered unless brought to the notice of the company in writing within 3 days of the receipt of the bill. ']
    sheet.add_row ['', '3     Dispute if any shall be subjected to the jurisdiction of Mumbai courts only.']
    
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['', "For #{@company.logistics_company&.name&.to_s}"]
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['', '(Authorised  Signatory)']    
  end

  private

  def for_each_site(trips)
    count = 0
    amount = 0
    trips.group_by(&:site_id).each do |site_id, trips|
      site = Site.find(site_id)
      @sheet.add_row ['', site.name], :style => [nil, @bold_align_center]
      tc, tam = yield(trips)
      count+= tc
      amount+= tam
    end
    @sheet.add_row ['', '', 'TOTAL', count, '', '', '','', '', amount], :style => [nil, @bold]

    @sheet.add_row ['']
    @sheet.add_row ['', "Add Service Tax  @ #{@company.service_tax_percent.to_f * 100}%", '', '', '', '', '', '', '', @company.service_tax_percent.to_f * amount], :style => [nil, @bold]
    @sheet.add_row ['', "Add: Swachh Bharat Cess  Amt @: #{@company.swachh_bharat_cess.to_f * 100}%", '', '', '', '', '', '', '', @company.swachh_bharat_cess.to_f * amount], :style => [nil, @bold]
    @sheet.add_row ['', "Add: Krishi Kalyan Cess  Amt @: #{@company.krishi_kalyan_cess.to_f * 100}%", '', '', '', '', '', '', '', @company.krishi_kalyan_cess.to_f * amount], :style => [nil, @bold]


    all_amount = amount *( 1 + @company.service_tax_percent.to_f + @company.swachh_bharat_cess.to_f + @company.krishi_kalyan_cess.to_f)

    @sheet.add_row ['', "Net Amount. ", '', '', '', '', '', '', '', all_amount], :style => [nil, @bold]
    @sheet.add_row ['', "Amount in words. ", all_amount.humanize], :style => [nil, @bold]
  end

  def to_words(num)
    numbers_to_name = {
        10000000 => "crore",
        100000 => "lakh",
        1000 => "thousand",
        100 => "hundred",
        90 => "ninety",
        80 => "eighty",
        70 => "seventy",
        60 => "sixty",
        50 => "fifty",
        40 => "forty",
        30 => "thirty",
        20 => "twenty",
        19=>"nineteen",
        18=>"eighteen",
        17=>"seventeen", 
        16=>"sixteen",
        15=>"fifteen",
        14=>"fourteen",
        13=>"thirteen",              
        12=>"twelve",
        11 => "eleven",
        10 => "ten",
        9 => "nine",
        8 => "eight",
        7 => "seven",
        6 => "six",
        5 => "five",
        4 => "four",
        3 => "three",
        2 => "two",
        1 => "one"
      }

    log_floors_to_ten_powers = {
      0 => 1,
      1 => 10,
      2 => 100,
      3 => 1000,
      4 => 1000,
      5 => 100000,
      6 => 100000,
      7 => 10000000
    }

    num = num.to_i
    return '' if num <= 0 or num >= 100000000

    log_floor = Math.log(num, 10).floor
    ten_power = log_floors_to_ten_powers[log_floor]

    if num <= 20
      numbers_to_name[num]
    elsif log_floor == 1
      rem = num % 10
      [ numbers_to_name[num - rem], to_words(rem) ].join(' ')
    else
      [ to_words(num / ten_power), numbers_to_name[ten_power], to_words(num % ten_power) ].join(' ')
    end
  end

  def for_each_vehicle(trips)
    count = 0
    total_amount = 0
    trips.group_by(&:vehicle_id).each do |vehicle_id, trips|
      vehicle = Vehicle.find(vehicle_id)
      group_by_pay_period = trips.group_by{|el| el.send(@company.pay_period)}

      extra_time =  group_by_pay_period.map do |_, tr|

        trip_dates = tr.map(&:start_date)
        driver_shifts = trip_dates.map{ |date| ::DriversShift.where(:vehicle_id => vehicle_id).where("start_time <= ? AND ? < end_time", date, date).first}.uniq
        shifts_durations = driver_shifts.sum(&:duration) rescue 0

        [0,  shifts_durations / 60 - @company.time_on_duty_limit].max
      end.reduce(:+)

      extra_distance = group_by_pay_period.map do |_, tr|
        [0, tr.sum(&:scheduled_approximate_distance) / 1000 - @company.distance_limit].max
      end.reduce(:+)
      amount = @company.standard_price * group_by_pay_period.count  + extra_distance * @company.rate_by_distance + extra_time * @company.rate_by_time

      count+= group_by_pay_period.keys.count
      total_amount+=amount
      @sheet.add_row ['', vehicle.plate_number, '', group_by_pay_period.keys.count, @company.rate_by_distance, @company.rate_by_time, @company.standard_price, extra_distance, extra_time, amount]
    end

    @sheet.add_row ['', '', 'TOTAL', count, '', '', '','', '', total_amount], :style => [nil, @bold]
    [count, total_amount]
  end
end