require 'services/trip_validation_service'

class EmployeeTripClustersDatatable
  include DatatablePagination

  delegate :params, to: :@view

  def initialize(view, current_user = nil, employee_trip_clusters = nil)
    @view = view
    @current_user = current_user
    @employee_trip_clusters = []
    if employee_trip_clusters.present?
      @employee_trip_clusters = employee_trip_clusters
      @is_nodal_allowed = TripValidationService.is_nodal_allowed
    end
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: @employee_trip_clusters.count,
        iTotalDisplayRecords: @employee_trip_clusters.count,
        aaData: data
    }
  end

  # TODO: mark employee trip as mised or smth
  def empl_trips
    name = params['search'].split(' ')
    if name[0].present? && name[1].present?
      query = 'users.f_name like "%' + name[0] + '%" and users.l_name like "%' + name[1] + '%"'
    else
      query = 'users.f_name like "%' + params['search'] + '%" or users.l_name like "%' + params['search'] + '%"'
    end

    if params['bus_rider'].blank?
      bus_rider = [true, false]
    else
      if params['bus_rider'] == '1'
        bus_rider = [true]
      else
        bus_rider = [false]
      end
    end

    filter_params_data = filter_params

    startDate = filter_params_data['startDate']
    endDate = filter_params_data['endDate']
    tripType = filter_params_data['trip_type']

    @employee_trips = EmployeeTrip.joins(:employee => [:site, :user])
      .joins(:employee_cluster)
      .where(query)
      .where(:trip_type => tripType)
      .where(:status => ['upcoming', 'unassigned', 'reassigned'])
      .where(:date => startDate..endDate)
      .where(:bus_rider => bus_rider)
      .where('employees.is_guard' => '0')
      .order('employee_trips.date ASC, employee_clusters.created_at ASC')
      .group_by{|e| [e.employee_trip_date, e.employee_cluster_id]}

    @clusters_array = []

    @employee_trips.map do |et|
      @clusters_array.push(et.last.first.employee_cluster_id)
    end

    EmployeeTrip
      .includes(:trip_route, :employee_cluster, :employee => [:user, :site])
      .where(:employee_cluster_id => @clusters_array)
      .where(:trip_type => tripType)
      .where(:status => ['upcoming', 'unassigned', 'reassigned'])
      .where(:date => startDate..endDate)
      .where(:bus_rider => bus_rider)
      .where('employees.is_guard' => '0')
      .order('employee_trips.date ASC, employee_clusters.created_at ASC')
      .group_by{|e| [e.employee_trip_date, e.employee_cluster_id]}
    # employee_trip.each do |et|
    #   puts "et.first #{et.first[0]} #{et.first[1]}"
    #   puts "et.last#{et.last}"
    # end
    # date = employee_trip.first
    # puts date
    # trips = employee_trip.last
    # puts date
    # puts trips
    # employee_trip
  end

  private

  def data
    @max_seats = Vehicle.maximum(:seats)
    if @max_seats.blank?
      @max_seats = 4
    end

    i = 0
    @employee_trip_clusters.map do |et|
      i = i + 1
      EmployeeTripClusterDatatable.new(et.first, et.last, i, @max_seats, @current_user, @is_nodal_allowed).data
    end

    # if(ENV["GEOHASH_AUTO_CLUSTERING"] == "true")
    #   i = -1
    #   employee_trip[0].map do |trip|
    #     i = i + 1
    #     EmployeeTripClusterDatatable.new(trip, employee_trip[0], employee_trip[1][i], employee_trip[1], @current_user).data
    #   end
    # else
    #   i = 0
    #   j = 0
    #   date = ""
    #   datetime = ""
    #   employee_trip.map do |trip|
    #     if j == 0
    #       if trip.has_attribute?(:date)
    #         date = trip.date.strftime("%H:%M")
    #         datetime = trip.date.strftime("%m/%d/%Y")
    #       else
    #         if trip.request_type == "cancel"
    #           date = trip.employee_trip.date.strftime("%H:%M")
    #           datetime = trip.employee_trip.date.strftime("%m/%d/%Y")              
    #         else
    #           date = trip.new_date.strftime("%H:%M")
    #           datetime = trip.new_date.strftime("%m/%d/%Y")              
    #         end
    #       end
    #     else
    #       if trip.has_attribute?(:date)
    #         if (j % 4 == 0) || date != trip.date.strftime("%H:%M") || datetime != trip.date.strftime("%m/%d/%Y")
    #           date = trip.date.strftime("%H:%M")
    #           datetime = trip.date.strftime("%m/%d/%Y")          
    #           i = i + 1
    #         end
    #       else
    #         if trip.request_type == "cancel"
    #           if (j % 4 == 0) || date != trip.employee_trip.date.strftime("%H:%M") || datetime != trip.employee_trip.date.strftime("%m/%d/%Y")
    #             date = trip.employee_trip.date.strftime("%H:%M")
    #             datetime = trip.employee_trip.date.strftime("%m/%d/%Y")          
    #             i = i + 1
    #           end              
    #         else
    #           if (j % 4 == 0) || date != trip.new_date.strftime("%H:%M") || datetime != trip.new_date.strftime("%m/%d/%Y")
    #             date = trip.new_date.strftime("%H:%M")
    #             datetime = trip.new_date.strftime("%m/%d/%Y")          
    #             i = i + 1
    #           end              
    #         end            
    #       end
    #     end

    #     j = j + 1
    #     EmployeeTripClusterDatatable.new(trip, employee_trip, trip.employee.zone.name, nil, @current_user).data      
    #   end      
    # end
  end

  # def employee_trip
  #   @trip ||= fetch_trip
  # end

  # def fetch_trip
  #   trip = empl_trips
  #   if @current_user.admin? || @current_user.employer? || (@current_user.transport_desk_manager? && ENV["ENABLE_TRANSPORT_DESK_MANAGER_APPROVE"] == "true") || @current_user.line_manager?
  #     trip = Kaminari.paginate_array(trip).page(page).per(per_page)
  #   else
  #     trip = trip.page(page).per(per_page)
  #   end
  #   trip
  # end
  
  # get params from date filter
  def filter_params 
    today = Time.zone.now.beginning_of_day.in_time_zone('UTC')
    tommorow = Time.zone.now.tomorrow.end_of_day.in_time_zone('UTC')
    startdate = Time.zone.parse(params['startDate']).in_time_zone('UTC') unless params['startDate'].blank?
    endDate = Time.zone.parse(params['endDate']).in_time_zone('UTC') unless params['endDate'].blank?
    tripType = params['direction'].blank? ? ['0', '1'] : params['direction']

    if params['bus_rider'].blank?
      bus_rider = [true, false]
    else
      if params['bus_rider'] == '1'
        bus_rider = [true]
      else
        bus_rider = [false]
      end
    end
    
    if params['endDate'].blank?
      employee_trip = EmployeeTrip
               .where(:status => ['upcoming', 'unassigned', 'reassigned'])
               .where(:trip_type => tripType)
               .where(:date => startdate..startdate.end_of_day)
               .where(:bus_rider => bus_rider)
               .order('employee_trips.date ASC')
               .limit(1)
               .first

      if employee_trip.present?
        endDate = employee_trip.date.in_time_zone('UTC')
      end
    end

    {
        'startDate' => startdate,
        'endDate'=> endDate.blank? ? startdate.end_of_day : endDate,
        'trip_type' => tripType
    }
  end

  def possible_sort_columns
    %w[status date]
  end

  # def set_zones 
  #   @employee_trips = EmployeeTrip.joins(:employee).where(:date => filter_params['startDate']..filter_params['endDate']).where(trip_type: filter_params['trip_type']).where(status: :upcoming).group_by(&:employee_trip_date)
  #   @zone = 1
  #   @ret_trips = []
  #   @ret_zones = []

  #   @employee_trips.each do |et|      
  #     #Refresh the employee_trips array
  #     size = 6
  #     @trips = EmployeeTrip.joins(:employee).where(trip_type: filter_params['trip_type']).where(status: :upcoming).where(date: et.last.first.date).order('employees.distance_to_site desc')

  #     while @trips.size > 0 do
  #       case size
  #       when 6
  #         @trips_grouped_by_geohash = @trips.group_by(&:employee_geohash_substring_six)
  #       when 5
  #         @trips_grouped_by_geohash = @trips.group_by(&:employee_geohash_substring_five)
  #       when 4
  #         @trips_grouped_by_geohash = @trips.group_by(&:employee_geohash_substring_four)
  #       when 3
  #         @trips_grouped_by_geohash = @trips.group_by(&:employee_geohash_substring_three)
  #       when 2
  #         break
  #       end

  #       @trips_grouped_by_geohash.each do |grouped_trips|
  #         if grouped_trips.last.size == 3 || grouped_trips.last.size == 4
  #           array_to_remove = []
  #           grouped_trips.last.each do |trip|
  #             #Set the zone for this
  #             @ret_trips.push(trip)
  #             @ret_zones.push(@zone)
  #             array_to_remove.push(trip)
  #           end
  #           @zone = @zone + 1
  #           @trips = @trips - array_to_remove
  #         elsif ((grouped_trips.last.size < 3) && (size <= 3)) || (grouped_trips.last.size > 4)
  #           int_arr = [grouped_trips.last.size]
  #           new_int_arr = int_arr

  #           while all_elements_are_less_than_equal_four(int_arr)
  #             new_int_arr = []
  #             int_arr.each do |i|
  #               if i > 4
  #                 i1 = i / 2
  #                 i2 = i - i1
  #                 new_int_arr.push(i1)
  #                 new_int_arr.push(i2)
  #               else
  #                 new_int_arr.push(i)
  #               end
  #             end
  #             int_arr = new_int_arr
  #           end
  #           new_int_arr.each do |arr|
  #             i = 0
  #             array_to_remove = []
  #             while i < arr
  #               i = i + 1
  #               trip = grouped_trips.last.shift
  #               @ret_trips.push(trip)
  #               @ret_zones.push(@zone)
  #               array_to_remove.push(trip)
  #             end
  #             @zone = @zone + 1
  #             @trips = @trips - array_to_remove
  #           end
  #         end
  #       end
  #       size = size - 1
  #     end
  #   end
  #   return @ret_trips, @ret_zones   
  # end

  # def all_elements_are_less_than_equal_four(int_arr)
  #   int_arr.each do |i|
  #     if i > 4
  #       return true
  #     end
  #   end
  #   return false
  # end
  
end
