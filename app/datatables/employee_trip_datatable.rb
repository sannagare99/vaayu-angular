class EmployeeTripDatatable
  def initialize(trip = nil, employee_trip = nil, zone = nil, selected_zones = nil, current_user = nil, nodal)
    @trip = trip
    @employee_trip = employee_trip
    # The zone which needs to be shown selected - Based on geo hash auto clustering
    @selected_zones = selected_zones
    #user defined zone variable
    @zone = zone
    #Save object of current user to be used for config based data
    @current_user = current_user

    @nodal = nodal
  end

  def as_json(options = {})
    {
        :data => data
    }
  end

  def data
    date = ""
    datetime = ""
    status = ""
    row_id = ""
    message = ""
    request_id = ""
    original_date = ""
    is_approver = false
    trip_type = ""
    address = ""
    area = ""
    pick_up_lat_lng = {}

    trip_type = @trip.trip_type

    if trip_type.blank?
      trip_type = @trip.employee_trip.trip_type
    end

    #if the user is not line manager, select the zones
    if !@current_user.line_manager?
      @selected_zone = selected_zone
      if @trip.has_attribute?(:date)
        row_id = "#{EmployeeTrip::DATATABLE_PREFIX}-#{@trip.id}"
        date = @trip.date.strftime("%d/%m/%Y")
        datetime = @trip.date.strftime("%I:%M %p")
      else
        row_id = "changereq-#{@trip.id}"
        if @trip.request_type == "cancel"
          date = @trip.employee_trip&.date&.strftime("%d/%m/%Y")
          datetime = @trip.employee_trip&.date&.strftime("%I:%M %p")        
        else
          date = @trip.new_date&.strftime("%d/%m/%Y")
          datetime = @trip.new_date&.strftime("%I:%M %p")
        end

        if @trip.request_type == "change"
          original_date = @trip.employee_trip&.date&.strftime("%d/%m/%Y %I:%M %p")
        end

        message = @trip.reason&.humanize
        request_id = @trip.id
        status = @trip.request_type.humanize
      end
    end

    if @current_user.admin? || @current_user.employer? || (@current_user.transport_desk_manager? && ENV["ENABLE_TRANSPORT_DESK_MANAGER_APPROVE"] == "true")
      is_approver = true
      if @trip.has_attribute?(:status)
        # trip_change_request = TripChangeRequest.where(:employee_trip => @trip).where(:request_state => 'created').order('id desc').first
        # if trip_change_request.present?
        #   if trip_change_request.request_type == "change"
        #     original_date = @trip.date&.strftime("%m/%d/%Y %I:%M %p")
        #   end
        #   if trip_change_request.request_type == "cancel"
        #     date = @trip.date.strftime("%d/%m/%Y")
        #     datetime = @trip.date.strftime("%I:%M %p")            
        #   else
        #     date = trip_change_request.new_date.strftime("%d/%m/%Y")
        #     datetime = trip_change_request.new_date.strftime("%I:%M %p")            
        #   end
        #   status = trip_change_request.request_type.humanize
        #   message = trip_change_request.reason.humanize
        #   request_id = trip_change_request.id

        #   address = trip_change_request.employee_trip.pick_up_address(@nodal)
        #   area = trip_change_request.employee_trip.area(@nodal)
        #   pick_up_lat_lng = trip_change_request.employee_trip.pick_up_lat_lng(@nodal)
        # else
        #   if @trip.bus_rider
        #     status = "#{@trip.status.humanize} - Nodal"
        #   else
        #     status = "#{@trip.status.humanize} - D2D"
        #   end
        #   address = @trip.pick_up_address(@nodal)
        #   area = @trip.area(@nodal)       
        #   pick_up_lat_lng = @trip.pick_up_lat_lng(@nodal) 
        # end
        if @trip.bus_rider
          status = "#{@trip.status.humanize} - Nodal"
        else
          status = "#{@trip.status.humanize} - D2D"
        end
        address = @trip.pick_up_address(@nodal)
        area = @trip.area(@nodal)       
        pick_up_lat_lng = @trip.pick_up_lat_lng(@nodal)         
      end
    end

    {
       "DT_RowId" => row_id,
       :status => status,
       :date => date,
       :datetime => datetime,
       :id => @trip.id,
       :employee_name => @trip.employee.user.f_name,
       :employee_id => @trip.employee.employee_id,
       :employee_l_name => @trip.employee.user.l_name,
       :sex => @trip.employee.gender.to_s.first.capitalize,
       :phone => @trip.employee.user.phone,
       :zone => @zone,
       :site => @trip.employee.site.name,
       :distance_to_site => @trip.employee.distance_to_site,
       :address => address,
       :site_lat => @trip.employee.site.latitude,
       :site_lng => @trip.employee.site.longitude,
       :selected_zone => selected_zone,
       :shift => date,
       :geohash => @trip.employee.geohash,
       :area => area,
       :trip_type => trip_type.humanize,
       :message => message,
       :request_id => request_id,
       :current_user => @current_user,
       :is_approver => is_approver,
       :original_date => original_date
    }.merge(pick_up_lat_lng)
  end

  private 

  def selected_zone
    return []
    # if(ENV["GEOHASH_AUTO_CLUSTERING"] == "true")
    #   if @employee_trip.blank?
    #     return []
    #   end

    #   select_zone = []
    #   @first_trip = @employee_trip.first
    #   @max_seats = Vehicle.maximum(:seats)

    #   if @max_seats.blank?
    #     @max_seats = 4
    #   end

    #   if @first_trip.has_attribute?(:date)
    #     select_zone.push("#{EmployeeTrip::DATATABLE_PREFIX}-#{@first_trip.id}")
    #     start_date = @first_trip&.date&.strftime("%d/%m/%Y")
    #     start_datetime = @first_trip&.date&.strftime("%I:%M %p")      
    #   else
    #     select_zone.push("changereq-#{@first_trip.id}")
    #     if @first_trip.request_type == "cancel"
    #       start_date = @first_trip.employee_trip&.date&.strftime("%d/%m/%Y")
    #       start_datetime = @first_trip.employee_trip&.date&.strftime("%I:%M %p")
    #     else
    #       start_date = @first_trip.new_date&.strftime("%d/%m/%Y")
    #       start_datetime = @first_trip.new_date&.strftime("%I:%M %p")
    #     end
    #   end

    #   flag = true
    #   size = 6
    #   while flag do
    #     substring = @first_trip.employee.geohash.first(size)
    #     trip_array = []
    #     @employee_trip.each_with_index do |trip, i|
    #       if i == 0
    #         next
    #       end
    #       if substring == trip.employee.geohash.first(size)
    #         trip_array.push(trip)
    #       end
    #     end

    #     if trip_array.size > 2 || size == 3
    #       flag = false
    #       j = 0
    #       trip_array.each do |trip_selected_zone|
    #         if j > @max_seats - 2
    #           break
    #         end
    #         if trip_selected_zone.has_attribute?(:date)
    #           if start_date != trip_selected_zone&.date&.strftime("%d/%m/%Y") || start_datetime != trip_selected_zone&.date&.strftime("%I:%M %p")
    #             break
    #           end
    #           select_zone.push("#{EmployeeTrip::DATATABLE_PREFIX}-#{trip_selected_zone.id}")
    #         else
    #         if trip_selected_zone.request_type == "cancel" || trip_selected_zone.request_type == "change"
    #           if start_date != trip_selected_zone.employee_trip&.date&.strftime("%d/%m/%Y") || start_datetime != trip_selected_zone.employee_trip&.date&.strftime("%I:%M %p")
    #             break
    #           end
    #         else
    #           if start_date != trip_selected_zone.new_date&.strftime("%d/%m/%Y") || start_datetime != trip_selected_zone.new_date&.strftime("%I:%M %p")
    #             break
    #           end
    #         end            
    #           select_zone.push("changereq-#{trip_selected_zone.id}")
    #         end
    #         j = j + 1
    #       end
    #     else
    #       size = size - 1
    #     end
    #   end

    #   select_zone
    # else
    #   # return @employee_trip.map.with_index do |trip, i|
    #   #   "empltrip-#{trip.id}" if trip.ingested?
    #   # end if @employee_trip.any?(&:ingested?)

    #   select_zone = []
    #   zone = ""
    #   date = ""
    #   datetime = ""

    #   @employee_trip.each_with_index do |trip, i|
    #     if i == 0
    #       zone = trip.employee.zone.name
    #       if trip.has_attribute?(:date)
    #         date = trip.date.strftime("%I:%M %p")
    #         datetime = trip.date.strftime("%d/%m/%Y")
    #       else
    #         date = trip.new_date.strftime("%I:%M %p")
    #         datetime = trip.new_date.strftime("%d/%m/%Y")
    #       end            
    #       select_zone.push("empltrip-" + trip.id.to_s)
    #       next
    #     end

    #     if trip.has_attribute?(:date)
    #       if zone == trip.employee.zone.name && date == trip.date.strftime("%I:%M %p") && datetime == trip.date.strftime("%d/%m/%Y")
    #         select_zone.push("empltrip-" + trip.id.to_s)
    #       end
    #     else
    #       if zone == trip.employee.zone.name && date == trip.new_date.strftime("%I:%M %p") && datetime == trip.new_date.strftime("%d/%m/%Y")
    #         select_zone.push("empltrip-" + trip.id.to_s)
    #       end          
    #     end
    #   end
    #   select_zone
    # end
  end
end
