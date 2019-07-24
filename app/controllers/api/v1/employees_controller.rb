module API::V1
  class EmployeesController < BaseController
    before_action :set_employee

    api :GET, '/employees/:id'
    description 'Returns employee profile data'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Employee cannot access some others profile'
    error code: 404, desc: 'Not found'
    example'
    {
      "user_id": 4,
      "username": "employee",
      "email": "employee@n3wnormal.com",
      "f_name": "Employee",
      "m_name": null,
      "l_name": "Test",
      "phone": "6665544",
      "profile_picture": null,
      "emergency_contact": {
        "name": null,
        "phone": null
      },
      "employer": {
        "name": "EmployeeCompany_test",
        "phone": "7776655"
      },
      "schedule": [
        {
          "day": 1,
          "check_in": "08:00",
          "check_out": "19:00"
        }
      ]
    }'
    def show
      authorize! :read, @employee
      @employee_shifts = @employee.shifts
    end


    api :PATCH, '/employees/:id'
    description 'Update employee profile data (emergency contacts)'
    param :id, :number, required: true
    param :employee, Hash, desc: 'Employee info' do
      param :emergency_contact_name, String, desc: 'Emergency contact name'
      param :emergency_contact_phone, String, desc: 'Emergency contact phone'
    end
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 422, desc: 'Unprocessable entity'
    error code: 404, desc: 'Not found'
    example'
    {
      "id": 32,
      "username": "employee",
      "email": "employee@n3wnormal.com",
      "f_name": "Employee",
      "m_name": null,
      "l_name": "Test",
      "phone": "6665544",
      "profile_picture": null,
      "emergency_contact": {
        "name": null,
        "phone": null
      },
      "employer": {
        "name": "employer name",
        "phone": "12345678"
      }
    }'
    def update
      authorize! :edit, @employee

      if @employee.update(employee_params)
        @employee.user.update_status(1)
        render 'show', status: 200
      else
        render json: @employee.errors, status: 422
      end
    end

    api :GET, '/employees/:id/upcoming_trip'
    description "Returns employee's most recent upcoming trip"
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Employee cannot access others data'
    error code: 404, desc: 'No upcoming trips found'
    example'
    {
      "id": 10,
      "trip_type": "check_out",
      "status": "trip_created",
      "schedule_date": 1478538000,
      "driver_arrive_date": 1478538600,
      "driver": {
        "user_id": 6,
        "username": "driver",
        "email": "driver@n3wnormal.com",
        "f_name": "Driver",
        "m_name": null,
        "l_name": "Test",
        "phone": "5554433",
        "profile_picture": null,
        "operating_organization": {
          "name": "LogisticsCompany_test",
          "phone": null
        }
      },
      "trip_change_request": {
          "id": 1,
          "request_type": "change",
          "reason": "emergency",
          "request_state": "created",
          "new_date": 1478636457
        }
    }'
    def upcoming_trip
      authorize! :read, @employee

      @employee_trip = @employee.closest_employee_trip
      @employee_shifts = @employee.shifts

      @change_time_check_in = Configurator.get('change_time_check_in')
      @change_time_check_out = Configurator.get('change_time_check_out')
      @cancel_time_check_in = Configurator.get('cancel_time_check_in')
      @cancel_time_check_out = Configurator.get('cancel_time_check_out')

      @change_time_check_in = formatted_duration(@change_time_check_in.to_i * 60)
      @change_time_check_out = formatted_duration(@change_time_check_out.to_i * 60)
      @cancel_time_check_in = formatted_duration(@cancel_time_check_in.to_i * 60)
      @cancel_time_check_out = formatted_duration(@cancel_time_check_out.to_i * 60)

      @consider_non_compliant_cancel_as_no_show = Configurator.get('consider_non_compliant_cancel_as_no_show') == '1'
      @change_request_require_approval = Configurator.get('change_request_require_approval') == '1'
    end

    api :GET, '/employees/:id/last_completed_trip'
    description "Returns employee's last not rated completed trip"
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Employee cannot access others data'
    error code: 404, desc: 'No upcoming trips found'
    example'
    {
      "id": 10,
      "trip_type": "check_out",
      "status": "trip_created",
      "schedule_date": 1478538000,
      "driver_arrive_date": 1478538600,
      "driver": {
        "user_id": 6,
        "username": "driver",
        "email": "driver@n3wnormal.com",
        "f_name": "Driver",
        "m_name": null,
        "l_name": "Test",
        "phone": "5554433",
        "profile_picture": null,
        "operating_organization": {
          "name": "LogisticsCompany_test",
          "phone": null
        }
      },
      "trip_change_request": {
          "id": 1,
          "request_type": "change",
          "reason": "emergency",
          "request_state": "created",
          "new_date": 1478636457
        }
    }'
    def last_completed_trip
      authorize! :read, @employee

      @employee_trip = @employee.last_completed_trip
      @employee_shifts = @employee.shifts

      @change_time_check_in = Configurator.get('change_time_check_in')
      @change_time_check_out = Configurator.get('change_time_check_out')
      @cancel_time_check_in = Configurator.get('cancel_time_check_in')
      @cancel_time_check_out = Configurator.get('cancel_time_check_out')

      @change_time_check_in = formatted_duration(@change_time_check_in.to_i * 60)
      @change_time_check_out = formatted_duration(@change_time_check_out.to_i * 60)
      @cancel_time_check_in = formatted_duration(@cancel_time_check_in.to_i * 60)
      @cancel_time_check_out = formatted_duration(@cancel_time_check_out.to_i * 60)

      @consider_non_compliant_cancel_as_no_show = Configurator.get('consider_non_compliant_cancel_as_no_show') == '1'
      @change_request_require_approval = Configurator.get('change_request_require_approval') == '1'

      render 'upcoming_trip', status: 200
    end
    
    api :GET, '/employees/:id/upcoming_trips'
    description "Returns employee's upcoming trips list"
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Employee cannot access others data'
    example'{
      "upcoming_trips": [
        {
          "id": 5,
          "trip_type": "check_in",
          "status": "upcoming",
          "schedule_date": 1479790800,
          "driver_arrive_date": 0,
          "trip_change_request": {
            "id": 1,
            "request_type": "change",
            "reason": "emergency",
            "request_state": "created",
            "new_date": 1479727527
          }
        },
        {
          "id": 6,
          "trip_type": "check_out",
          "status": "upcoming",
          "schedule_date": 1479823200,
          "driver_arrive_date": 0
        },
        {
          "id": 7,
          "trip_type": "check_in",
          "status": "upcoming",
          "schedule_date": 1479877200,
          "driver_arrive_date": 0
        },
        {
          "id": 8,
          "trip_type": "check_out",
          "status": "upcoming",
          "schedule_date": 1479909600,
          "driver_arrive_date": 0
        },
        {
          "id": 9,
          "trip_type": "check_in",
          "status": "upcoming",
          "schedule_date": 1479963600,
          "driver_arrive_date": 0
        },
        {
          "id": 10,
          "trip_type": "check_out",
          "status": "upcoming",
          "schedule_date": 1479996000,
          "driver_arrive_date": 0
        }
      ],
      "trips_change_requests": [
        {
          "id": 1,
          "request_type": "change",
          "reason": "emergency",
          "request_state": "created",
          "new_date": 1479727527
        },
        {
          "id": 2,
          "request_type": "new_trip",
          "reason": null,
          "request_state": "created",
          "new_date": 1479727527
        }
      ]
    }'
    def upcoming_trips
      authorize! :read, @employee
      if params[:shift] == "true"
        @employee_trips = @employee.employee_trips.upcoming.not_completed.scheduled.order(date: :asc)
        @employee_trip_change_requests = @employee.trip_change_requests.new_trip.where(:shift => true).where(:request_state => 'created')
      else
        @employee_trips = @employee.employee_trips.upcoming.not_completed.order(date: :asc)
        @employee_trip_change_requests = @employee.trip_change_requests.new_trip.where(:request_state => 'created')
      end
    end

    api :GET, '/employees/:id/trip_history'
    description "Returns employee's list of completed trips"
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Employee cannot access others data'
    example'[
      {
        "id": 1,
        "trip_type": "check_in",
        "status": "completed",
        "approximate_driver_arrive_date": 1483939200,
        "approximate_drop_off_date": 1483941000,
        "actual_driver_arrive_date": 1483615020,
        "actual_drop_off_date": 1483615202
      },
      {
        "id": 3,
        "trip_type": "check_in",
        "status": "completed",
        "approximate_driver_arrive_date": 1484025600,
        "approximate_drop_off_date": 1484027400,
        "actual_driver_arrive_date": 1483615410,
        "actual_drop_off_date": 1483615434
      }
    ]'
    def trip_history
      authorize! :read, @employee
      @employee_trips = @employee.employee_trips.completed.joins(:trip).order('trips.start_date DESC, employee_trips.date DESC').limit(20)
    end

    api :POST, '/employees/:id/call_operator'
    description 'Connect operator and employee'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'User cannot access trip he does not belongs to'
    error code: 404, desc: 'Trip not found'
    example '
    {
      "success": true
    }'
    def call_operator
      @employee.call_operator(params[:id])
    end

    def update_user_status
      current_user.update_status(2)
    end

    protected
    def set_employee
      @employee = Employee.find_by_user_id(params[:id])
    end

    def employee_params
      params.require(:employee).permit(:emergency_contact_name, :emergency_contact_phone)
    end

    def formatted_duration(total_seconds)
      total_minutes = total_seconds / 60

      hours = (total_minutes / 60).to_i
      minutes = (total_minutes % 60).to_i

      time = ""
      if hours != 0
        time = time + "#{ hours } hours"
      end
      if minutes != 0
        time = time + " #{minutes} minutes"
      end

      time
    end    
  end
end
