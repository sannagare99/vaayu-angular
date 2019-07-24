require 'services/google_service'
require 'services/clustering_service'
require 'services/trip_validation_service'

class HomeController < TripValidationController
  include ReportsHelper
  skip_before_action :authenticate_user!, :only => [:exotel_callback, :offline_sms_get, :offline_sms_post, :release_info]

  def index
    employee_satisfaction
    completed_trips
    on_time_arrivals
    exceptions
    fleet_utilization    
  end

  def profile_edit
    if !current_user.driver? || !current_user.employee?
      @user = current_user
    else
      flash[:error] = 'Sorry, you have not permissions'
      redirect_to root_path
    end
  end

  def profile_update

  end

  # Dashboard Exceptions statistics
  def exceptions
    alarms = TripRouteException.where(:date => get_range).count
    car_broke_down = Notification.where(:created_at => get_range).where('message = "car_broke_down" or message = "car_broke_down_trip"').count

    alarms_resolved = TripRouteException.where(:date => get_range).where(:status => :closed).count
    car_broke_down_resolved = Notification.where(:created_at => get_range).where(:resolved_status => true).where('message = "car_broke_down" or message = "car_broke_down_trip"').count
    @exceptions = {
        :alarm => alarms + car_broke_down,
        :alarm_resolved => alarms_resolved + car_broke_down_resolved,
        :panic => TripRouteException.where(:exception_type => :panic).where(:date => get_range).count,
        :not_on_board => TripRouteException.where(:exception_type => :not_on_board).where(:date => get_range).count,
        :car_broke_down => car_broke_down,
        :still_on_board => TripRouteException.where(:exception_type => :still_on_board).where(:date => get_range).count,
        :driver_no_show => TripRouteException.where(:exception_type => :driver_no_show).where(:date => get_range).count,
        :employee_no_show => TripRouteException.where(:exception_type => :employee_no_show).where(:date => get_range).count
    }
  end

  # Dashboard Employee Satisfaction diagrams
  def employee_satisfaction
    employee_trips = EmployeeTrip.where(:status => 'completed').where(:date => get_range)
    total_rating = 0
    under_expectation = 0
    employee_ratings = 0
    employee_trips.each do |employee_trip|
      if employee_trip.rating.present?
        employee_ratings += 1
        total_rating += employee_trip.rating
        if employee_trip.rating <= 3
          under_expectation += 1
        end
      else
        total_rating += 5
      end
    end

    @employee_satisfaction = {
        :average_rating    => zero_if_raise {(total_rating.to_f / employee_trips.count).round(2)},
        :under_expectation => zero_if_raise {(under_expectation.to_f / employee_trips.count).round(2)},
        :employee_percentage => zero_if_raise {((employee_ratings.to_f / employee_trips.count) * 100).round(2)}
    }
  end

  # Dashboard Completed Trips statistics
  def completed_trips
    trips = Trip.where(:status => 'completed').where(:start_date => get_range)
    trip_routes = TripRoute.joins(:trip).where("trips.status = 'completed'").where('trips.start_date' => get_range)
    trip_routes_total = TripRoute.joins(:trip).where('trips.scheduled_date' => get_range)

    total_trips = Trip.where(:scheduled_date => get_range)  
    mileage_per_trip = zero_if_raise{(trips.sum(:scheduled_approximate_distance).to_f / trips.count.to_f) / 1000}
    mileage_per_employee = zero_if_raise{(trips.sum(:scheduled_approximate_distance).to_f / trip_routes.count.to_f) / 1000}
    duration_per_trip = zero_if_raise{ trips.sum(:real_duration).to_f / trips.count.to_f}
    duration_per_employee = zero_if_raise{ trips.sum(:real_duration).to_f / trip_routes.count.to_f}

    @completed_trips_data = {
        :manifest_fulfiled => zero_if_raise {((trips.count.to_f / total_trips.count.to_f) * 100).round(2)},
        :employees_catered => zero_if_raise {((trip_routes.count.to_f / trip_routes_total.count.to_f) * 100).round(2)},
        :total_mileage => trips.sum(:scheduled_approximate_distance) / 1000,
        :mileage_per_employee => mileage_per_employee.round(2),
        :mileage_per_trip => mileage_per_trip.round(2),
        :duration_per_employee => formatted_duration(duration_per_employee),
        :duration_per_trip => formatted_duration(duration_per_trip),
        :total_duration => formatted_duration(trips.sum(:real_duration))
    }
  end

  def formatted_duration(total_minutes)
    hours = zero_if_raise {(total_minutes / 60).to_i}
    minutes = zero_if_raise{(total_minutes % 60).to_i}

    if hours == 0
      "#{ minutes } m"
    else
      "#{ hours } h #{ minutes } m"
    end
  end

  # Dashboard On Time Arrivals statistics
  def on_time_arrivals
    total_trips = Trip.where(:status => 'completed').where(:start_date => get_range).count
    on_time_check_in_trips = Trip.joins(:employee_trips)
                           .where(:status => 'completed')
                           .where(:start_date => get_range)
                           .where(:trip_type => :check_in)
                           .where("trips.completed_date < employee_trips.date").group('trips.id').count.count

    on_time_check_out_trips = Trip.joins(:employee_trips)
                           .where(:status => 'completed')
                           .where(:start_date => get_range)
                           .where(:trip_type => :check_out)
                           .where("trips.completed_date < employee_trips.date").group('trips.id').count.count

    trips =  Trip.joins(:trip_routes).where(:status => 'completed').where(:start_date => get_range)
    total_emp = (trips.count == 0) ? 1 : trips.count.to_f

    check_in_trips = Trip.joins(:trip_routes).where(:status => 'completed').where(:start_date => get_range).where(:trip_type => :check_in)
    check_out_trips = Trip.joins(:trip_routes).where(:status => 'completed').where(:start_date => get_range).where(:trip_type => :check_out)

    total_check_in_trips = check_in_trips.count
    total_check_out_trips = check_out_trips.count


    # on_time_check_in = Trip.joins(:employee_trips)
    #                        .where(:status => 'completed')
    #                        .where(:start_date => get_range)
    #                        .where(:trip_type => :check_in)
    #                        .where("trip_routes.driver_arrived_date < employee_trips.date").count

    # on_time_check_out = Trip.joins(:employee_trips)
    #                            .where(:status => 'completed')
    #                            .where(:start_date => get_range)
    #                            .where(:trip_type => :check_out)
    #                            .where("'trips.completed_date' < 'employee_trips.date'").count


    no_show_check_in  =  check_in_trips.where("trip_routes.status = 'missed'").count.to_f
    no_show_check_out = check_out_trips.where("trip_routes.status = 'missed'").count.to_f

    # on_time_first_check_in = Trip.where(:status => 'completed')
    #                              .where(:start_date => get_range)
    #                              .where(:trip_type => :check_in)
    #                              .where(:scheduled_date >= :start_date).count
    # on_time_first_check_out =  Trip.where(:status => 'completed')
    #                                .where(:start_date => get_range)
    #                                .where(:trip_type => :check_out)
    #                                .where(:scheduled_date >= :start_date).count

    trip_routes = TripRoute.joins(:trip).where("trips.status = 'completed'").where('trips.start_date' => get_range)

    on_time_first_check_in = on_time_first_check_out = on_time_check_in = on_time_check_out = total_delay_check_in = total_delay_check_out = total_wait_time_check_in = total_wait_time_check_out = total_delay_check_in_count = total_delay_check_out_count = 0

    trips.each do |trip|
      trip_route = TripRoute.where(:trip => trip).order('driver_arrived_date asc').where.not(:status => ['canceled']).first
      if trip_route.present? && !trip_route.driver_arrived_date.blank?
        if trip_route.approximate_driver_arrive_date < trip_route.driver_arrived_date
          if trip_route.check_trip_type == 'check_in'
            on_time_first_check_in += 1
          else
            on_time_first_check_out += 1
          end
        end
      end
    end

    trip_routes.each do |trip_route|
      delay = 0
      if trip_route.driver_arrived_date.blank? || trip_route.on_board_date.blank?
        next
      end
      
      if trip_route.approximate_driver_arrive_date < trip_route.driver_arrived_date
        if trip_route.check_trip_type == 'check_in'
          on_time_check_in += 1
        else
          on_time_check_out += 1
        end        
      end

      wait = zero_if_raise{(trip_route.on_board_date - trip_route.driver_arrived_date) / 1.minutes}
      wait_time = wait > 0 ? wait : 0
      delay = (trip_route.approximate_driver_arrive_date - trip_route.driver_arrived_date) / 1.minutes
      delay = delay > 0 ? delay : 0

      # if trip_route.driver_arrived_date > trip_route.employee_trip.date
      #   wait = zero_if_raise{(trip_route.on_board_date - trip_route.driver_arrived_date) / 1.minutes}
      #   wait_time = wait > 0 ? wait : 0
      # else
      #   delay = (trip_route.employee_trip.date - trip_route.driver_arrived_date) / 1.minutes
      #   wait = zero_if_raise{ (trip_route.on_board_date - trip_route.employee_trip.date)} / 1.minutes
      #   wait_time = wait > 0 ? wait : 0
      # end

      if wait_time > 0 || delay > 0
        if trip_route.trip.check_in?
          total_delay_check_in += delay
          total_wait_time_check_in +=  wait_time
          total_delay_check_in_count += 1
        else
          total_delay_check_out += delay
          total_wait_time_check_out +=  wait_time
          total_delay_check_out_count += 1
        end
      end
    end

    # puts "trips #{trips}"
    # puts "on_time_check_in_trips #{on_time_check_in_trips}"
    # puts "on_time_check_out_trips #{on_time_check_out_trips}"
    # puts "total_trips #{total_trips}"
    # puts "total_emp #{total_emp}"
    # puts "total_check_in_trips #{total_check_in_trips}"
    # puts "total_check_out_trips #{total_check_out_trips}"
    # puts "on_time_check_in #{on_time_check_in}"
    # puts "on_time_check_out #{on_time_check_out}"
    # puts "no_show_check_in #{no_show_check_in}"
    # puts "no_show_check_out #{no_show_check_out}"
    # puts "on_time_first_check_in #{on_time_first_check_in}"
    # puts "on_time_first_check_out #{on_time_first_check_out}"
    # puts "get_range #{get_range}"

    @on_time_arrivals = {
        :late => zero_if_raise{ (((on_time_check_in_trips + on_time_check_out_trips).to_f / total_trips) * 100).round },

        :on_time_check_in => zero_if_raise{ ((on_time_check_in.to_f / total_check_in_trips) * 100).round },
        :on_time_check_out => zero_if_raise{ ((on_time_check_out.to_f / total_check_out_trips) * 100).round },

        :on_time => zero_if_raise{ (((on_time_check_in + on_time_check_out).to_f / total_emp) * 100).round },

        :on_time_first_check_in => zero_if_raise{ ((on_time_first_check_in.to_f / total_check_in_trips)* 100).round },
        :on_time_first_check_out => zero_if_raise{ ((on_time_first_check_out.to_f / total_check_out_trips)* 100).round },

        :no_show_check_in => zero_if_raise{ ((no_show_check_in.to_f / total_check_in_trips)* 100).round },
        :no_show_check_out => zero_if_raise{ ((no_show_check_out.to_f / total_check_out_trips)* 100).round },

        :no_show => zero_if_raise{ ((trips.where("trip_routes.status = 'missed'").count.to_f / total_emp) * 100).round },

        :avg_delay => zero_if_raise{ ((total_delay_check_in + total_delay_check_out).to_f / total_emp).round },
        :avg_wait => zero_if_raise{ ((total_wait_time_check_in + total_wait_time_check_out).to_f / total_emp).round },

        :delay_check_in_count => zero_if_raise{((total_delay_check_in_count.to_f / total_check_in_trips)* 100).round},
        :delay_check_out_count => zero_if_raise{((total_delay_check_out_count.to_f / total_check_out_trips)* 100).round},

        :avg_delay_check_in => zero_if_raise{ (total_delay_check_in.to_f / total_check_in_trips).round },
        :avg_wait_check_in => zero_if_raise{ (total_wait_time_check_in.to_f / total_check_in_trips).round },

        :avg_delay_check_out => zero_if_raise{ (total_delay_check_out.to_f / total_check_out_trips).round },
        :avg_wait_check_out => zero_if_raise{ (total_wait_time_check_out.to_f / total_check_out_trips).round }
    }

  end

  def fleet_utilization
    vehicles_in_trip_count = Trip.where(:status => 'completed').where(:start_date => get_range).select('vehicle_id').group('vehicle_id').count.length
    vehicles_on_duty_count = DriversShift.where(:start_time => get_range).select('vehicle_id').group('vehicle_id').count.length

    total_vehicles = Vehicle.count
    trips = Trip.where(:status => 'completed').where(:start_date => get_range)
    seats = employees = 0
    trips.each do |trip|
      seats += trip.vehicle.seats
      employees += trip.employee_trips.count
    end

    @fleet_utilization = {
        :fleet_idleness => zero_if_raise {vehicles_in_trip_count.to_f / vehicles_on_duty_count.to_f},
        :capacity_utilization => zero_if_raise {(employees.to_f / seats.to_f) * 100},
        :trips_per_vehicle => zero_if_raise {(trips.count.to_f / vehicles_in_trip_count.to_f).round(2)},
        :vehicles_on_duty_count => vehicles_on_duty_count,
        :vehicles_waiting_for_assignment => total_vehicles - vehicles_on_duty_count
    }

  end

  #make call
  def initiate_call    
    response = make_call(:To => params[:To], :From => current_user.phone, :CallerId => ENV['EXOTEL_CALLER_ID'], :CallType => 'trans', :StatusCallback => "http://#{ENV['SERVER_URL']}/exotel_callback")

    @user = User.where(:phone => params[:To]).first

    if @user.present? && !params[:notification].blank?
      notification = Notification.where(id: params[:notification]).first
      if @user.driver?
        reporter = "Operator: #{Current.user.full_name}"
        Notification.create!(:trip => notification.trip, :driver => @user.entity, :message => 'employee_called_driver', :resolved_status => true,:new_notification => true, :reporter => reporter).send_notifications
      elsif @user.employee?
        reporter = "Operator: #{Current.user.full_name}"
        Notification.create!(:trip => notification.trip, :employee => @user.entity, :message => 'driver_called_employee', :resolved_status => true,:new_notification => true, :reporter => reporter).send_notifications
      end
    end

    # unless params[:notification].blank?
    #   # Save call SID in the notification table to check for callback and mark the notification resolved
    #   notification = Notification.where(id: params[:notification]).first
    #   if notification.present? && !response["TwilioResponse"]["Call"].nil?
    #     notification.update!(call_sid: response["TwilioResponse"]["Call"]["Sid"])
    #   end
    # end
    result = {json: 'Call initiated by the user', status: '400'}
  end

  #make call
  def exotel_callback
    # if params["Status"] == "completed"
    #   notification = Notification.where(call_sid: params["CallSid"]).first
    #   if notification.present?
    #     notification.update!(resolved_status: true)
    #   end
    # end
  end

  def update_last_active_time
    current_user.update!(:last_active_time => Time.now)
  end
  
  def badge_count
    vehicle_tab_notify_count = vehicle_tab_notify
    driver_tab_notify_count = driver_tab_notify
    @badge_count = {
        :unresolved_notification_count => unresolved_notification_count,
        :active_trips_count => active_trips_count,
        :assigned_trips_count => assigned_trips_count,
        # :adhoc_trips_count => adhoc_trips_count,
        :unassigned_trips_count => unassigned_trips_count,
        :completed_trips_count => completed_trips_count,
        :new_notifications => new_notifications,
        :leave_requests_count => leave_requests_count,
        :trip_rosters_count => trip_rosters_count,
        :manifest_count => manifest_count,
        :vehicle_tab_notify => vehicle_tab_notify_count,
        :driver_tab_notify => driver_tab_notify_count,
        :provisioning_tab_notify => vehicle_tab_notify_count || driver_tab_notify_count
    }

    render :json => @badge_count
  end

  def vehicle_tab_notify
    notification_count = ComplianceNotification.where(:status => :active).where.not(:vehicle => nil).count

    vehicle_pending_status = Vehicle.where(:status => ['vehicle_ok_pending', 'vehicle_broke_down_pending']).count
    # count = DriverRequest.where(:request_type => 'car_broke_down').where(:request_state => [:cancel, :pending]).count
#     count = DriverRequest.find_by_sql('SELECT t1.*
# FROM driver_requests t1
# WHERE t1.request_date = (SELECT MAX(t2.request_date)
#                  FROM driver_requests t2
#                  WHERE t2.vehicle_id = t1.vehicle_id)
# AND t1.request_state in ("pending", "canceled")').count
    if notification_count > 0 || vehicle_pending_status > 0
      return true
    end
    return false
  end
  
  def driver_tab_notify
    count = DriverRequest.where(:request_type => 'on_leave').where('start_date > ?', Time.now).where(:request_state => [:cancel, :pending]).count

    notification_count = ComplianceNotification.where(:status => :active).where.not(:driver => nil).count

    if count > 0 || notification_count > 0
      return true
    end
    return false
  end

  def auto_cluster
    if params['bus_rider'] == 1
      create_bus_trip_clusters(params["ids"], params["trip_type"])
    else
      if params[:strategy] == 'historical' || ENV['CLUSTER_ALGORITHM'] == 'historical'
        create_trip(params["ids"], params["trip_type"], params['startDate'], params['endDate'])
      elsif ENV['CLUSTER_ALGORITHM'] == 'clustering_service'
        employee_trips = EmployeeTrip.where(id: params['ids'])
        vehicles = Vehicle
          .where('id not in (select vehicle_id from cluster_vehicles where date in (?))', employee_trips.pluck(:date).uniq) if params[:fleet_mix].blank?
        res = ClusteringService.auto_cluster({
          strategy: params[:strategy],
          threshold: params[:threshold].to_f,
          fleet_mix: params[:fleet_mix],
          vehicle_ids: vehicles&.pluck(:id),
          large_vehicle: params[:large_vehicle].to_f,
          route_deviation: params[:route_deviation].to_f,
          check_female_exception: params[:check_female_exception],
          cluster_alone_threshold: params[:cluster_alone_threshold].to_f,
          employee_trip_ids: employee_trips.pluck(:id)
        })
        res.each do |cluster|
          ec = EmployeeCluster.new
          ets = employee_trips.select do |et|
            cluster['employees'].map {|e| e['id']}.include?(et.employee_id) if cluster['employees']
          end.sort_by do |et|
            cluster['employees'].map {|e| e['id']}.index(et.employee_id) if cluster['employees']
          end
          ec.date = ets.first.date unless ets.blank?
          if TripValidationService.is_female_exception(
              ets.pluck(:id),
              ets.first.trip_type)
            ec.error = [ec.error, 'female_exception'].compact.join(', ')
            res = TripValidationService.resequence_employee_trips(
              ets.pluck(:id),
              ets.first.trip_type)
            if !res[:sorted_employee_trip_ids].blank?
              ets = EmployeeTrip.where(id: res[:sorted_employee_trip_ids])
              ec.error = [ec.error, 'route_resequenced'].compact.join(', ')
            end
          end
          ec.save
          ets.each.with_index do |et,i|
            et.update({
              route_order: i,
              is_clustered: true,
              employee_cluster: ec,
            })
          end
          ClusterVehicle.create(date: ets.first.date,
                                vehicle_id: cluster['vehicle']['id'],
                                employee_cluster: ec)
        end
      end
    end
    render :json => {success: true}
  rescue
    render json: {error: 'Something went wrong'}, status: 500
  end

  def offline_sms_get
    @success = {
        :success => true
    }

    #puts "--------------------"
    #puts "Get SMS called"
    #puts Time.now.in_time_zone('Chennai')
    #puts params['message']
    #puts JSON.parse(params['message'].split(' ')[1])
    #puts "--------------------"

    keyword = params['message'].split(' ')[0]
    #data = JSON.parse(params['message'].split(' ')[1])
    data = JSON.parse(params['message'][keyword.length..-1])
    @driver = User.find(data['uid'])
    #@auth_token_driver = @driver.create_new_auth_token

    #token = @driver.tokens.max_by { |cid, v| v[:expiry] || v["expiry"] }
    #@auth_token_driver = @driver.build_auth_header(token[1]["token"], token[0])

    @params = {
        :'is_from_sms' => 'true',
        :'uid' => data['uid']
    }
    if data['trip_routes'].present?
      @params = {
        :'trip_routes' => data['trip_routes'].split(","),
        :'is_from_sms' => 'true',
        :'uid' => data['uid']
      }
    end

    if data.key?('plate_number')
      @params_plate_number = {
        :'plate_number' => data['plate_number'],
        :'is_from_sms' => 'true',
        :'uid' => data['uid']
      }
    end   

    case data['action']
      when 'start_trip'
        @params = {
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
        }

        if data['trip_routes'].present?
          @params = {
            :'trip_routes' => data['trip_routes'].split(","),
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
          }
        end
        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/trips/#{data['trip_id']}/start"),
        {
          :query => @params
          #:headers => @auth_token_driver
        })
      when 'driver_arrived'
        @params = {
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
        }

        if data['trip_routes'].present?
          @params = {
            :'trip_routes' => data['trip_routes'].split(","),
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
          }
        end

        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/trips/#{data['trip_id']}/trip_routes/driver_arrived"),
        {
          :body => @params,
          #:headers => @auth_token_driver
        })
      when 'on_board'
        @params = {
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
        }

        if data['trip_routes'].present?
          @params = {
            :'trip_routes' => data['trip_routes'].split(","),
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
          }
        end

        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/trips/#{data['trip_id']}/trip_routes/on_board"),
        {
          :body => @params,
          #:headers => @auth_token_driver
        })
      when 'completed'
        @params = {
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
        }

        if data['trip_routes'].present?
          @params = {
            :'trip_routes' => data['trip_routes'].split(","),
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
          }
        end

        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/trips/#{data['trip_id']}/trip_routes/completed"),
        {
          :body => @params,
          #:headers => @auth_token_driver
        })
      when 'resolve_exception'
        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/trips/#{data['trip_id']}/trip_routes/resolve_exception"),
        {
          :body => @params,
          #:headers => @auth_token_driver
        })
      when 'employee_no_show'
        @params = {
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
        }

        if data['trip_routes'].present?
          @params = {
            :'trip_routes' => data['trip_routes'].split(","),
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
          }
        end

        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/trip_routes/#{data['trip_route_id']}/employee_no_show"),
        {
          :query => @params
          #:headers => @auth_token_driver
        })
      when 'go_on_duty'
        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/on_duty"),
        {
          #:headers => @auth_token_driver,
          :query => @params_plate_number
        })
      when 'go_off_duty'
        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/off_duty"),
        {
          #:headers => @auth_token_driver
          :query => @params
        })
      when 'change_vehicle'
        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/change_vehicle"),
        {
          #:headers => @auth_token_driver,
          :query => @params_plate_number
        })
      when 'car_broke_down'
        @params_car_broke_down = {
          :'request_type' => 'car_broke_down',
          :'is_from_sms' => 'true',
          :'uid' => data['uid']
        }
        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/driver_request"),
        {
          :body => @params_car_broke_down,
          #:headers => @auth_token_driver
        })
      when 'vehicle_ok_now'
        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/vehicle_ok_now"),
        {
          #:headers => @auth_token_driver
          :query => @params
        })
      when 'upcoming_trip'
        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/upcoming_trip"),
        {
          #:headers => @auth_token_driver
          :query => @params
        })
      when 'last_trip_request'
        @params_last_trip_request = {
          :'trip_id' => data['trip_id'],
          :'is_from_sms' => 'true',
          :'uid' => data['uid']
        }

        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/last_trip_request"),
        {
          #:headers => @auth_token_driver,
          :query => @params_last_trip_request
        })
      when 'accept_trip'
        @params = {
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
        }

        if data['trip_routes'].present?
          @params = {
            :'trip_routes' => data['trip_routes'].split(","),
            :'is_from_sms' => 'true',
            :'uid' => data['uid'],
            :'request_date' => data['request_date']
          }
        end
                
        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/trips/#{data['trip_id']}/accept_trip_request"),
        {
          #:headers => @auth_token_driver
          :query => @params
        })
      when 'call_operator'
        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/call_operator"),
        {
          #:headers => @auth_token_driver
          :body => @params
        })
      when 'call_employee'
        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/trip_routes/#{data['trip_route_id']}/initiate_call"),
        {
          #:headers => @auth_token_driver
          :body => @params
        })
      when 'driver_upcoming_trip'
        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/upcoming_trip"),
        {
          #:headers => @auth_token_driver
          :query => @params
        })
      when 'driver_full_trip'
        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/trips/#{data['trip_id']}"),
        {
          :query => @params
          #:headers => @auth_token_driver
        })
      when 'request_leave'
        @params_leave = {
          :'request_type' => 'leave',
          :'start_date' => data['start_date'],
          :'end_date' => data['end_date'],
          :'is_from_sms' => 'true',
          :'uid' => data['uid']
        }
        response = HTTParty.post(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/driver_request"),
        { 
          :body => @params_leave,
          #:headers => @auth_token_driver
        })
      when 'report_to_duty'
        response = HTTParty.get(URI.escape("http://0.0.0.0/api/v1/drivers/#{data['uid']}/report_to_duty"),
        {
          :query => @params
          #:headers => @auth_token_driver
        })
      
    end

    action = data["action"]

    no_show_approval = false
    no_show_approval_required = Configurator.where(:request_type => 'no_show_approval_required').first

    if no_show_approval_required.present?
      no_show_approval = no_show_approval_required.value
    end    
    
    if response.code == 200
      @success = {
          success: true,
          action: data["action"],
          trip_route_id: data["trip_route_id"],
          no_show: no_show_approval,
          uuid: data["uuid"],
          response_code: response.code,
          response: response
      }
      #render :json => @success
      # SMSWorker.perform_async(params['from'].last(10).to_s, ENV['OPERATOR_NUMBER'], @success.to_json)
    else
      @success = {
          success: false,
          action: data["action"],
          uuid: data["uuid"],
          response_code: response.code,
          response: response
      }
      #render :json => @success
      # SMSWorker.perform_async(params['from'].last(10).to_s, ENV['OPERATOR_NUMBER'], @success.to_json)
    end

    #@success = {
    #    :success => true
    #}

    render :json => @success
  end

  def offline_sms_post
    puts "offline_sms_post"
    @success = {
        :success => true
    }

    render :json => @success
  end

  def sorted_routes
    render :json => TripValidationService.get_sorted_routes(params[:ids])
  end

  def release_info
    render json: {
      commit: `git rev-parse --short HEAD`.strip,
      branch: `git rev-parse --abbrev-ref HEAD`.strip
    }
  end

  private
  # Get period for dashboard reports
  def get_range
    today_start_of_day = (Time.now.in_time_zone('Chennai')).beginning_of_day
    case params['period']
      when 'day'
        [today_start_of_day..Time.now.in_time_zone('Chennai')]
      when 'week'
        [today_start_of_day - 1.week..today_start_of_day]
      when 'month'
        [today_start_of_day - 1.month..today_start_of_day]
      else
        [today_start_of_day..Time.now.in_time_zone('Chennai')]
    end
  end

  def make_call(params)
    HTTParty.post(URI.escape("https://#{ENV['EXOTEL_SID']}:#{ENV['EXOTEL_TOKEN']}@twilix.exotel.in/v1/Accounts/#{ENV['EXOTEL_SID']}/Calls/connect"),
    {
      :query => params,
      :body => params
    })
  end

  def unresolved_notification_count
    @count = 0
    case current_user.role
      when 'employer'
        company = current_user.entity.employee_company.logistics_company
        @count = Notification.joins(:driver).where(:receiver => [1,2], :status => 0,'drivers.logistics_company_id' => company&.id, :resolved_status => false, :sequence => 3).count
      when 'operator'
        company = current_user.entity.logistics_company
        @count = Notification.joins(:driver).where(:receiver => [0,2], :status => 0,'drivers.logistics_company_id' => company&.id, :resolved_status => false, :sequence => 3).count
      when 'admin'
        @count = Notification.where(:status => 0, :resolved_status => false, :sequence => 3).count
    end
    @count
  end

  def active_trips_count
    @count = Trip.where(:status => 'active').count
  end

  def adhoc_trips_count
    @count = TripChangeRequest.where(:request_state => 'created').count
  end

  def assigned_trips_count
    @count = Trip.where(:status => ['assigned', 'assign_requested', 'assign_request_expired']).count
  end

  def unassigned_trips_count
    @count = Trip.where(:status => ['created', 'assign_request_declined']).count
  end

  def manifest_count
    @count = Trip.where(:status => ['created', 'assign_request_declined', 'assign_requested', 'assign_request_expired']).count
  end

  def completed_trips_count
    @count = Trip.where(:status => ['canceled', 'completed']).count
  end

  def trip_rosters_count
    @count = Trip.where(:status => ['created', 'assign_request_declined', 'assigned', 'assign_request_expired', 'assign_requested']).count
  end  

  def new_notifications
    @count = 0
    case current_user.role
      when 'employer'
        company = current_user.entity.employee_company.logistics_company
        @count = Notification.joins(:driver).where(:receiver => [1,2], :status => 0, :new_notification => true, 'drivers.logistics_company_id' => company.id).count
      when 'operator'
        company = current_user.entity.logistics_company
        @count = Notification.joins(:driver).where(:receiver => [0,2], :status => 0, :new_notification => true, 'drivers.logistics_company_id' => company.id).count
      when 'admin'
        @count = Notification.where(:status => 0, :new_notification => true).count
    end
    if @count > 0
      true
    else
      false
    end
  end

  def leave_requests_count
    DriverRequest.where(:request_state => ['pending', 'cancel']).count
  end

  #Auto Cluster functions
  $assigned_drivers = []

  def create_bus_trip_clusters(ids, trip_type)
    @employee_trips = EmployeeTrip.joins(:employee).where(:id => ids).where(trip_type: trip_type).where(status: :upcoming).where(bus_rider: true).group_by(&:employee_trip_date)

    employee_trips_array = []

    @employee_trips.each do |et|
      @trips = EmployeeTrip.joins(:employee).where(:id => ids).where(trip_type: trip_type).where(status: :upcoming).where(date: et.last.first.date).where(bus_rider: true).group_by(&:employee_bus_trip_id)
      @trips.each do |grouped_trips|
        ec = EmployeeCluster.create(date: grouped_trips.last.first.date)        
        grouped_trips.last.each do |trip|
          #Set the zone for this
          trip.update!(:is_clustered => true, employee_cluster: ec)
        end        
      end
    end
  end

  # get params from date filter
  def filter_params(start_date, end_date, tripType)
    today = Time.zone.now.beginning_of_day.in_time_zone('UTC')
    tommorow = Time.zone.now.tomorrow.end_of_day.in_time_zone('UTC')
    startdate = Time.zone.parse(start_date).in_time_zone('UTC') unless start_date.blank?
    endDate = Time.zone.parse(end_date).in_time_zone('UTC') unless end_date.blank?

    bus_rider = [false]

    if params['endDate'].blank?
      employee_trip = EmployeeTrip.joins(:employee => [:site])
         .where(:status => ['upcoming', 'unassigned', 'reassigned'])
         .where(:trip_type => tripType)
         .where(:bus_rider => bus_rider)
         .where(:date => startdate..startdate.end_of_day)
         .order('employee_trips.date ASC')
         .limit(1)
         .first

      new_trip_request = []

      if !bus_rider
        new_trip_request = TripChangeRequest.joins(:employee)
            .where(:request_type => :new_trip)
            .where(:request_state => 'created')
            .where(:new_date => startdate..startdate.end_of_day)
            .where(:trip_type => tripType)
            .order('trip_change_requests.new_date ASC')
            .limit(1)
            .first
      end

      if employee_trip.present?
        endDate = employee_trip.date.in_time_zone('UTC')
      end

      if new_trip_request.present?
        if endDate.blank? || new_trip_request.new_date.in_time_zone('UTC') < endDate
          endDate = new_trip_request.new_date.in_time_zone('UTC')
        end
      end
    end
    
    {
        'startDate' => startdate,
        'endDate'=> endDate.blank? ? startdate.end_of_day : endDate,
        'trip_type' => tripType
    }
  end
  def create_trip(ids, trip_type, start_date, end_date)
    # @clustered_employee_trips = EmployeeTrip.joins(:employee).where(:id => ids).where.not(employee_cluster: nil)

    # @clustered_employee_trips.each do |et|
    #   # For ingested trips
    #   et.update(status: :upcoming, :is_clustered => true)
    # end
    filter_params = filter_params(start_date, end_date, trip_type)

    startDate = filter_params['startDate']
    endDate = filter_params['endDate']
    trip_type = filter_params['trip_type']

    employee_trip_request = EmployeeTrip
           .find_by_sql("select count(*) as count, b.date
              from employee_trips as a inner join employee_trips as b on 
              (a.employee_id = b.employee_id and 
              a.date = CONCAT(date('#{startDate}'), ' ', time(b.date))) where 
              a.date >= '#{startDate}' and 
              a.date <= '#{endDate}' and
              a.status = 'upcoming' and
              a.employee_cluster_id is null and 
              a.trip_type = #{trip_type} and
              a.bus_rider = 0
              and Date(b.date) <= Date('#{startDate - 1.day}') AND 
              Date(b.date) >= Date('#{startDate - 7.day}') and
              time(b.date) >= time('#{startDate}') and 
              time(b.date) <= time('#{endDate}') and 
              b.trip_id is not null and
              b.trip_type = #{trip_type} and
              b.bus_rider = 0 group by b.date;")
    
    max_count = 0
    time_difference = 7

    employee_trip_request.each do |et|
      if et.count > max_count
        time_difference = (startDate.in_time_zone(Time.zone).beginning_of_day - et.date.beginning_of_day).to_i
        time_difference = (time_difference / 60 / 60 / 24)
        max_count = et.count
      end
    end

    # employee_trip_request_1 = EmployeeTrip
    #        .select("employee_trips.employee_id, SUBSTRING_INDEX(SUBSTRING_INDEX(date, ' ', 2), ' ', -1) as time, date")
    #        .joins(:employee => [:site, :user])
    #        .where(:bus_rider => false)
    #        .where(:status => ['upcoming', 'unassigned', 'reassigned'])
    #        .where(:trip_type => trip_type)
    #        .where(:employee_cluster => nil)
    #        .where('employees.is_guard' => '0')
    #        .where(:date => startDate-0.day..endDate-0.day)
    #        .group_by(&:employee_trip_date_substring)


    # @employee_trips = EmployeeTrip.find_by_sql("select employee_id, SUBSTRING_INDEX(SUBSTRING_INDEX(date, ' ', 1), ' ', -1) as day, 
    #   SUBSTRING_INDEX(SUBSTRING_INDEX(date, ' ', 2), ' ', -1) as time, 
    #   trip_type from employee_trips where trip_type = 1")

    id_string = ''
    ids.each do |id|
      id_string = "#{id_string},#{id}"
    end

    id_string[0] = ''

    @employee_trips = EmployeeTrip.find_by_sql("select a.date, a.id as next_id, b.id as prev_id, b.trip_id from 
      employee_trips a inner join employee_trips b where a.employee_id = b.employee_id and 
      a.date = date_add(b.date, INTERVAL #{time_difference} DAY) and a.trip_type = b.trip_type and b.trip_id is not null and a.id in (#{id_string}) order by b.trip_id")

    trip_id = ''
    employee_cluster = nil
    @employee_trips.each do |et|
      # puts "#{et.date} #{et.next_id} #{et.prev_id} #{et.trip_id}"
      if trip_id != et.trip_id
        trip_id = et.trip_id
        #Create a new cluster for this date
        employee_cluster = EmployeeCluster.create(date: et.date)
      end


      prev_emp_trip = EmployeeTrip.find(et.prev_id)
      next_emp_trip = EmployeeTrip.find(et.next_id)

      if prev_emp_trip.trip_route.present?
        next_emp_trip.update(route_order: prev_emp_trip.trip_route.scheduled_route_order, employee_cluster: employee_cluster)
      else
        next_emp_trip.update(employee_cluster: employee_cluster)
      end
    end
    # @employee_trips = EmployeeTrip.joins(:employee).where(:id => ids).group_by(&:employee_trip_date)

    # @employee_trips.each do |et|
    #   @employee_ids = []
    #   et.last.each do |e|
    #     @employee_ids.push(e.employee_id)
    #   end

    #   @last_week_employee_trips = EmployeeTrip.where(:employee_id => @employee_ids).where(:date => et.last.first.date - 7.days)

    #   @trips = []

    #   @last_week_employee_trips.each do |emp_trip|
    #     @trips.push(emp_trip.trip_id)
    #   end

    #   @trips = @trips.uniq


    #   @trips.each do |trip|
    #     @et = EmployeeTrip.where(:trip_id => trip)

    #     @employee_ids_in_trip = []

    #     @et.each do |e|
    #       @employee_ids_in_trip.push(e.employee_id)
    #     end

    #     @next_et = EmployeeTrip.eager_load(:trip_route).where(:employee_id => @employee_ids_in_trip).where(:date => @et.first.date + 7.days).where(:status => 'upcoming')

    #     next if @next_et.blank?

    #     #Mark cluster id as null for each employee trip
    #     # @next_et.each do |next_et|
    #     #   next_et.update(employee_cluster: nil)
    #     # end

    #     employee_cluster = EmployeeCluster.create(date: @et.first.date + 7.days)
    #     @next_et.each do |employee_trip|
    #       employee_trip.update(employee_cluster: employee_cluster)
    #       @et.each do |e|
    #         if e.employee_id == employee_trip.employee_id && e.trip_route.present?
    #           employee_trip.update(route_order: e.trip_route.scheduled_route_order)
    #           break
    #         end
    #       end
    #     end        
    #   end
    # end

    # #Create clusters for bus trips
    # @employee_trips = EmployeeTrip.joins(:employee).where(:id => ids).where(:zone => nil).where(trip_type: trip_type).where(status: :upcoming).where(bus_rider: true).group_by(&:employee_trip_date)

    # employee_trips_array = []

    # @employee_trips.each do |et|
    #   @trips = EmployeeTrip.joins(:employee).where(:id => ids).where(:zone => nil).where(trip_type: trip_type).where(status: :upcoming).where(date: et.last.first.date).where(bus_rider: true).group_by(&:employee_bus_trip_id)
    #   @trips.each do |grouped_trips|
    #     employee_trips_array = []
    #     #Get the next available zone
    #     zone_id = EmployeeTrip.where(date: grouped_trips.last.first.date).where(trip_type: trip_type).maximum(:zone)
    #     if !zone_id
    #       zone_id = 1
    #     else
    #       zone_id = zone_id + 1
    #     end        
    #     grouped_trips.last.each do |trip|
    #       #Set the zone for this
    #       employee_trips_array.push(trip.id.to_s)
    #     end
    #     create_employee_trip(employee_trips_array, zone_id, "") 
    #   end
    # end

    # #Create clusters for normal trips
    # @employee_trips = EmployeeTrip.joins(:employee).where(:zone => nil).where(:id => ids).where(trip_type: trip_type).where(status: :upcoming).where(bus_rider: false).group_by(&:employee_trip_date)
    # #@employee_trips = EmployeeTrip.joins(:employee).where(trip_type: trip_type).where(status: :upcoming).order('employees.geohash ASC').group_by(&:employee_trip_date)
    # max_employees = Vehicle.maximum(:seats)

    # @employee_trips.each do |et|
    #   #Refresh the employee_trips array
    #   size = 6
    #   @trips = EmployeeTrip.joins(:employee).where(:id => ids).where(:zone => nil).where(trip_type: trip_type).where(status: :upcoming).where(date: et.last.first.date).where(bus_rider: false).order('employees.geohash asc')

    #   while @trips.size > 0 do
    #     employee_trips_array = []
    #     case size
    #     when 6
    #       @trips_grouped_by_geohash = @trips.group_by(&:employee_geohash_substring_six)
    #     when 5
    #       @trips_grouped_by_geohash = @trips.group_by(&:employee_geohash_substring_five)
    #     when 4
    #       @trips_grouped_by_geohash = @trips.group_by(&:employee_geohash_substring_four)
    #     when 3
    #       @trips_grouped_by_geohash = @trips.group_by(&:employee_geohash_substring_three)
    #     when 2
    #       break
    #     end

    #     @trips_grouped_by_geohash.each do |grouped_trips|
    #       if ((grouped_trips.last.size < max_employees) && (size <= 3)) || (grouped_trips.last.size > 2)
    #         array_to_remove = []
    #         grouped_trips.last.each do |trip|
    #           #Set the zone for this
    #           employee_trips_array.push(trip.id.to_s)
    #           array_to_remove.push(trip)
    #         end
    #         if size <= 3
    #           create_valid_employee_trips(array_to_remove[0].date, employee_trips_array, size, trip_type)
    #         else  
    #           create_valid_employee_trips(array_to_remove[0].date, employee_trips_array, max_employees, trip_type)
    #         end
    #         @trips = @trips - array_to_remove
    #       end
    #     end
    #     size = size - 1
    #   end
    # end 
  end

  def create_valid_employee_trips(date, employee_trips_array, max_employees, trip_type)
    #Get the next available zone
    zone_id = EmployeeTrip.where(date: date).where(trip_type: trip_type).maximum(:zone)
    if !zone_id
      zone_id = 1
    else
      zone_id = zone_id + 1
    end

    # Maximum calacity of vehicle
    number_of_employees = max_employees      
    while employee_trips_array.present? do
      if number_of_employees <= employee_trips_array.size
        sliced_employee_trips = employee_trips_array[0..number_of_employees - 1]
      else
        number_of_employees = employee_trips_array.size
        sliced_employee_trips = employee_trips_array[0..number_of_employees - 1]
      end

      #Check if the trip can be made for these 4 employees
      ret = check_if_valid_trip(sliced_employee_trips, trip_type)
      case ret
        when 'failed'
          employee_trips_array = employee_trips_array - sliced_employee_trips
        when 'empty'
          return
        when 'female_filter_failed'
          if number_of_employees == max_employees
            number_of_employees -= 1
            puts "Deleting an employee from the list due to #{ret}" 
          else
            #Create a trip for these employees and start with next list of employees
            puts "Created a new trip for #{sliced_employee_trips.size} employees even with #{ret}, need to add a guard in this"
            create_employee_trip(sliced_employee_trips, zone_id, ret)
            zone_id = zone_id + 1
            employee_trips_array = employee_trips_array - sliced_employee_trips
            #Again start with 4 employees
            sliced_employee_trips.each do |et|
              puts et
            end

            number_of_employees = max_employees           
          end
        when 'max_distance_failed', 'max_duration_failed'
          if number_of_employees > 1
            number_of_employees -= 1
            puts "Deleting an employee from the list due to #{ret}" 
          else
            #Create a trip for these employees and start with next list of employees
            puts "Create a new trip for single employee even with #{ret}"
            create_employee_trip(sliced_employee_trips, zone_id, ret)
            zone_id = zone_id + 1
            employee_trips_array = employee_trips_array - sliced_employee_trips            
            #Again start with 4 employees
            sliced_employee_trips.each do |et|
              puts et
            end            
            number_of_employees = max_employees
          end
        when 'passed'
          #Create a trip for these employees and start with next list of employees
          create_employee_trip(sliced_employee_trips, zone_id)
          zone_id = zone_id + 1
          employee_trips_array = employee_trips_array - sliced_employee_trips            
          puts "Create a new trip for #{sliced_employee_trips.size} employees without any error"
          #Again start with 4 employees
          sliced_employee_trips.each do |et|
            puts et
          end          
          number_of_employees = max_employees
      end
    end
  end

  def create_employee_trip(employee_trip_ids, zone_id, ret = "")
    employee_trip = EmployeeTrip.where(:id => employee_trip_ids)
    employee_trip.each do |et|
      et.update!(:zone => zone_id, :is_clustered => true)
      if ret != "" || ret != "passed"
        et.update!(:cluster_error => ret)
      end
    end
    # @trip = Trip.new(:employee_trip_ids_with_prefix=>employee_trip_ids)
    # @trip.site = @trip.employee_trips.first.employee.site
    # if @trip.save
    #   puts "*****"
    #   puts "Trip was created successfully"
    #   puts "*****"
    #   if add_guard
    #     @employee = Employee.guard.where("id not in (?)", Employee.not_available.map(&:id)).first
    #     if @employee.present?
    #       @trip.add_guard_to_trip(@employee.id)
    #       assign_driver(@trip)
    #     end
    #   else
    #     #Assign driver for the trip
    #     assign_driver(@trip)
    #   end
    # else
    #   puts "*****"
    #   puts @trip.errors.full_messages.to_sentence
    #   puts "*****"
    # end
  end

  def assign_driver(trip)
    @drivers = Driver.where(:site => @trip.site)        
    @on_duty_drivers = @drivers.on_duty

    @active_drivers = Driver.eager_load(:trips).where(:site => trip.site).where('trips.status' => ['active']).on_duty

    @available_drivers = @on_duty_drivers - @active_drivers - $assigned_drivers

    if @available_drivers.blank?
      return
    end

    min_distance = 9999999
    best_driver = []
    @available_drivers.each do |driver|
      if driver.user.current_location.blank?
        puts "No Current location available for the driver"
        next
      end
      
      driver_location = driver.user.current_location
      if trip.check_in?
        trip_route = trip.trip_routes.order('scheduled_route_order ASC').first
        if trip_route.present?
          first_pick_up_location = trip_route.planned_start_location  
        else
          puts "No trip route found"
          next
        end
      elsif trip.check_out?
        first_pick_up_location = trip.site_location_hash
      end

      route = GoogleService.new.directions(
          driver_location,
          first_pick_up_location,
          mode: 'driving',
          avoid: 'tolls',
          departure_time: Time.now.in_time_zone('Chennai')
      )
      route_data = route.first[:legs]
      duration = (route_data[0][:duration_in_traffic][:value].to_f / 60).ceil

      if duration < min_distance
        min_distance = duration
        best_driver = driver
      end
    end

    if best_driver.present?
      if trip.update(:driver => best_driver, :vehicle => best_driver.vehicle)
        if trip.assign_driver!
          $assigned_drivers.push(best_driver)
          puts "Driver updated successfully"
        else
          puts "Error in assigning Driver"
        end
      end    
    end
  end
end
