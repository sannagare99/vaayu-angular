class BusTripsController < ApplicationController
  before_action :set_bus_trip, only: [:update, :toggle_state]

  def index
    respond_to do |format|
      format.html
      format.json { render json: BusTripsDatatable.new(view_context)}
    end
  end

  def new
    
  end

  def edit
    @bus_trip = BusTrip.find(params[:id])
    @bus_trip_routes = BusTripRoute.where(:bus_trip => @bus_trip)
    render :new
  end

  def create
    @bus_trip = BusTrip.create!(:route_name => params[:route_name])
    params['stop'].each do |stop|
      bus_stop = params['stop']["#{stop}"]
      BusTripRoute.create!(:name => params[:route_name] + '-' + bus_stop[:name],:stop_name => bus_stop[:name],:stop_address => bus_stop[:address],:stop_order => bus_stop[:order], :bus_trip => @bus_trip)
    end
    render json: true, status: 200
  end

  def update
    @bus_trip.update!(:route_name => params[:route_name])
    params[:stop].each do |stop|
      bus_stop = params['stop']["#{stop}"]
      @bus_trip_route = @bus_trip.bus_trip_routes.where(:stop_order => bus_stop[:order]).first      
      if @bus_trip_route.blank?
        BusTripRoute.create!(:name => params[:route_name] + '-' + bus_stop[:name],:stop_name => bus_stop[:name],:stop_address => bus_stop[:address],:stop_order => bus_stop[:order], :bus_trip => @bus_trip)
      else
        @bus_trip_route.update!(:name => params[:route_name] + '-' + bus_stop[:name],:stop_name => bus_stop[:name], :stop_address => bus_stop[:address])
      end
    end
    render json: true, status: 200
  end

  def destroy
  end

  def toggle_state
    if @bus_trip.operating?
      @bus_trip.stop!
    else
      @bus_trip.activate!
    end

    respond_to do |format|
      format.json { render json: {}, status: :ok }
    end
  end

  private

  def set_bus_trip
    @bus_trip = BusTrip.find_by_prefix(params[:id])
  end  
end