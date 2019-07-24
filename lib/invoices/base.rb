class Invoices::Base
  attr_reader :company, :invoice_frequency, :pay_period, :trips_groups, :trips, :amount, :invoice, :period, :trips_count

  def initialize(id)
    @invoice_frequency = @company.invoice_frequency
    @pay_period = @company.pay_period
  end

  def generate
    @trips_groups = fetch_trips_in_batches
    @amount = calculate_invoice_amount
    create_invoice
    generate_xls
  end

  private

  def generate_xls
    filename = ApplicationHelper.sanitize_filename("invoice-#{@company.name.to_s}-#{@invoice.date&.strftime("%Y-%m-%d")}") + ".xlsx"
    xls = Invoices::Files::Xls.new(@company, @period, @trips, @invoice, filename)
    xls.build
  end

  def create_invoice
    @invoice = @company.invoices.create(
        :date => Time.now,
        :start_date => @period.first,
        :end_date=> @period.second,
        :trips_count => @trips_count,
        :amount => @amount
    )
  end

  def fetch_trips_in_batches
    if @company.pay_period_before_type_cast > @company.invoice_frequency_before_type_cast + 1
      @pay_period = @invoice_frequency
    end

    yesterday = Time.now - 1.day
    @period = case @invoice_frequency
               when 'day'
                 [yesterday.beginning_of_day - 1.day, yesterday.end_of_day - 1.day]
               when 'week'
                 [yesterday.beginning_of_week_in_current_month, yesterday.end_of_week_in_current_month]
               when 'month'
                 [yesterday.beginning_of_month, yesterday.end_of_month]
               else
                 []
             end

    get_trips(@period)
  end

  def calculate_invoice_amount
    amount = 0
    @trips_count = 0
    @trips_groups.each do |_, trips|
      @trips_count += trips.count
      trips_by_cars = trips.group_by{ |trip| trip.vehicle}
      trips_by_cars.each do |v_id,t|
        # TODO: refactor this!!! Performance issue
        trip_dates = t.map(&:start_date)
        driver_shifts = trip_dates.map{ |date| ::DriversShift.where(:vehicle_id => v_id).where("start_time <= ? AND ? < end_time", date, date).first}.uniq
        shifts_durations = driver_shifts.sum(&:duration) rescue 0

        distance_cost = [0, t.sum(&:scheduled_approximate_distance) / 1000 - @company.distance_limit].max * @company.rate_by_distance
        duration_cost = [0, shifts_durations / 60 - @company.time_on_duty_limit].max * @company.rate_by_time

        amount += @company.standard_price + distance_cost + duration_cost
      end
    end
    # calculate amount with tax
    amount * (1 + @company.service_tax_percent + @company.swachh_bharat_cess + @company.krishi_kalyan_cess)
  end
end