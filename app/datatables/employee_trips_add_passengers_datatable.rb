class EmployeeTripsAddPassengersDatatable
  include DatatablePagination

  delegate :params, to: :@view

  def initialize(view, current_user = nil)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: empl_trips.count,
        iTotalDisplayRecords: empl_trips.count,
        aaData: data
    }
  end

  # TODO: mark employee trip as mised or smth
  def empl_trips
    if params['bus_rider'].to_s == 'true'
      bus_rider = true
    elsif params['bus_rider'].to_s == 'false'
      bus_rider = false
    end    
    employee_trip = EmployeeTrip.joins(:employee => [:site])
               .where(:status => ['upcoming', 'unassigned', 'reassigned'])
               .where(:date => params['date'])
               .where(:trip_type => params['trip_type'])
               .where(:employee_cluster_id => nil)
               .where(:bus_rider => bus_rider)
               .where('employees.is_guard' => '0')
               .order('employee_trips.date ASC')

    employee_trip.sort do |a,b|
      date1 = ""
      date2 = ""
      if a.has_attribute?(:date)
        date1 = a.date
      elsif a.has_attribute?(:new_date) && a.request_type == "cancel"
        date1 = a.new_date
      else
        date1 = a.employee_trip.date
      end

      if b.has_attribute?(:date)
        date2 = b.date
      elsif b.has_attribute?(:new_date) && b.request_type == "cancel"
        date2 = b.new_date
      else
        date2 = b.employee_trip.date
      end

      if date1 == date2
        a.employee.geohash <=> b.employee.geohash
      else
        date1 <=> date2
      end
    end

    employee_trip
  end

  private

  def data
    empl_trips.map do |et|
      EmployeeTripsAddPassengerDatatable.new(et).data
    end
  end

  def possible_sort_columns
    %w[status date zone]
  end
end
