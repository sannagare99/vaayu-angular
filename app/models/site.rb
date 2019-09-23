require 'services/google_service'

class Site < ApplicationRecord
  extend AdditionalFinders
  DATATABLE_PREFIX = 'site'

  belongs_to :employee_company
  has_many :employees
  has_many :drivers
  has_many :trips
  has_many :services, :dependent => :destroy
  has_many :shifts

  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :employee_company, presence: true

  def location
    [ latitude, longitude ]
  end

  def location_hash
    {:lat => latitude.to_f, :lng => longitude.to_f}
  end

  def generate_invoice
    @invoice = Invoice.new(:company_id => self.employee_company_id, 
                      :date => Time.now(),
                      :status  => 'new'
                      )
    @service = Service.where(:site => self).first
    status = ['completed', 'canceled']
    @trips = Trip.where(:status => status).where(:site => self).where(:scheduled_date => (Time.now - 1.day).beginning_of_month..(Time.now - 1.day).end_of_month)
    @trips.each do |trip|
      if trip.cancel_status != 'Driver Didn’t Complete'
        bill_amount = generate_invoice_for_trip(trip, @service)
        Trip.where(:id => trip.id).update_all({:toll=>bill_amount['toll'], :penalty => bill_amount['penalty'], :amount => bill_amount['amount'], :paid => 1})
        TripInvoice.create!(:invoice_id => @invoice.id, 
                        :trip_id => trip.id,
                        :trip_amount => bill_amount['amount'],
                        :trip_penalty => bill_amount['penalty'],
                        :trip_toll => bill_amount['toll'],
                        :vehicle_rate_id => 0,
                        :zone_rate_id => 0
                        )
      end
    end    
  end

  protected
  # Update site address coordinates on every save
  def set_site_coordinates
    return errors.add(:address, 'Please provide the address.') if address.blank?

    self.latitude = nil
    self.longitude = nil

    # Geocoding an address
    results = GoogleService.new.geocode(address).first

    unless results.nil? || ! results.key?(:geometry)
      coordinates = results[:geometry][:location]
      self.latitude = coordinates[:lat]
      self.longitude = coordinates[:lng]
    end
  end

  def generate_invoice_for_trip(trip, service)
    #TODO ignoring overage as of now
    vehicle = Vehicle.where(:id => trip.vehicle_id).first
    billing_zone = trip.employee_trips.collect {|employee_trip| employee_trip.employee[:billing_zone]}.uniq
    is_guard = 0
    vehicle_rate = nil
    zone_rate = nil
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
      zone_rate = ZoneRate.where(:vehicle_rate_id => vehicle_rate.id).where(:name => 'Default').first
    elsif service.billing_model == 'Fixed Rate per Zone'
      if service.vary_with_vehicle
        puts "********** case Zone - vehicle ***********"        
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => vehicle.seats).where(:ac => vehicle.ac).first        
      else
        puts "********** case zone - NO vehicle ***********"
        vehicle_rate = VehicleRate.where(:service_id => service.id).where(:vehicle_capacity => 0).first
      end
      zone_rate = ZoneRate.where(:vehicle_rate_id => vehicle_rate.id).where(:name => billing_zone).order(rate: :desc).first
    end
    calculate_cost(vehicle_rate, zone_rate, is_guard)
  end

  def calculate_cost(vehicle_rate, zone_rate, is_guard)
    amount = 0
    if is_guard
      amount = zone_rate[:rate] + zone_rate[:guard_rate]
    else
      amount = zone_rate[:rate]
    end    
    bill_amount = {
      'amount' => amount,
      'penalty' => 0,
      'toll' => 0,
      'zone_rate_id' => zone_rate[:id],
      'vehicle_rate_id' => vehicle_rate[:id]
    }
  end  
end
