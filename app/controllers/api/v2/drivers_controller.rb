module API::V2
  class DriversController < BaseController
    before_action :set_driver

    api :POST, '/drivers/:id/update_current_location'
    description 'Update the current location for on duty driver and send a push to all employees on that trip for real time update'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'Driver not found'
    example'
    {
      "success": true,
      "updatedETA": "updated ETA"
    }'
    def update_current_location
      authorize! :read, @driver

      trip_id = ""
      @trip_array = []
      params["values"].each do |location|
        if trip_id != location["nameValuePairs"]["tripId"]
          trip_id = location["nameValuePairs"]["tripId"]
          @trip = Trip.where(id: trip_id).first
          if !@trip.blank?    
            @trip_array.push(@trip)
          else
            next
          end
        end
        if !@trip.blank?
          @trip.set_trip_location({:lat => location["nameValuePairs"]["lat"].to_f, :lng => location["nameValuePairs"]["lng"].to_f}, location["nameValuePairs"]["distance"], location["nameValuePairs"]["speed"], location["nameValuePairs"]["time"])
        end
      end

      render '_success', status: 200
    end

    api :GET, '/drivers/:id/last_trip_request'
    description 'Get latest available trip request. Will be deprecated when push notifications would be done'
    param :id, :number, required: true
    formats [ :json ]
    error code: 401, desc: 'Unauthorized'
    error code: 403, desc: 'Driver cannot access others data'
    error code: 404, desc: 'Driver not found'
    example'
    {
      "id": 2,
      "status": "assign_requested",
      "trip_type": "check_in",
      "date": 1479106800
    }'
    def last_trip_request
      authorize! :read, @driver

      @trip = @driver.trips.where(:id => params[:trip_id]).where(:status => ['assign_requested', 'assign_request_expired']).order(assign_request_expired_date: :asc).last
    end

    def vehicle_info
      @vehicles = Vehicle.where("replace(lower(plate_number), ' ', '') LIKE replace(?, ' ', '')", "%#{params[:vehicle_id]}%")
      puts @vehicles
      if @vehicles.blank?
        render '_errors', status:422
      end
    end

    protected

    def set_driver
      @driver = Driver.find_by_user_id(params[:id])
    end
  end
end
