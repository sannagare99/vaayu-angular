require 'geohash'
require 'services/google_service'

class Employee < ApplicationRecord
  extend AdditionalFinders
  include UserData
  after_create :create_schedule
  after_create :check_if_bus_travel_changed
  after_update :check_if_bus_travel_changed
  # before_validation :set_home_address_coordinates
  # before_validation :calculate_distance_to_site
  before_save :calculate_distance_to_site

  DATATABLE_PREFIX = 'employee'

  has_one :user, :as => :entity, :dependent => :destroy
  belongs_to :site
  belongs_to :bus_trip_route
  belongs_to :zone
  belongs_to :zone_rate
  belongs_to :employee_company
  belongs_to :line_manager
  has_many   :employee_schedules, :dependent => :destroy
  has_many   :employee_trips, :dependent => :destroy
  has_many :trip_change_requests, dependent: :destroy
  has_many :shifts, through: :user

  accepts_nested_attributes_for :employee_schedules
  enum gender: [:female, :male]

  validates :gender, presence: true
  validates :home_address, presence: true
  validates :home_address_latitude, presence: true
  validates :home_address_longitude, presence: true
  # validates :nodal_address, presence: true
  # validates :nodal_address_latitude, presence: true
  # validates :nodal_address_longitude, presence: true
  validates :site, presence: true
  validates :employee_company, presence: true
  # validate :home_address_location_calculated
  # validate :distance_to_site_calculated

  scope :not_guard, -> { where(is_guard: false) }
  scope :guard, -> { where(is_guard: true) }
  scope :not_available, -> { joins(:employee_trips).where("employee_trips.status not in (?)", ["completed", "canceled", "missed"]) }

  attr_accessor :shift_ids

  def employer_name
    employee_company.try(:name)
  end

  def process_code
    process_code = User.where(:entity_id => self.id).first&.process_code
    if process_code.blank?
      process_code = '--'
    end
    process_code
  end

  def employer_phone
    employee_company.employers.first.try(:phone)
  end

  def self.find_by_user_id(user_id)
    Employee.joins(:user).merge(User.employee.where(id: user_id)).first
  end

  # Get first upcoming employee trip
  def last_completed_trip
    @employee_trip = employee_trips.where(status: :current).not_dismissed.order(date: :desc).limit(1).first
    if @employee_trip.blank? || (@employee_trip.trip_route.present? && @employee_trip.trip_route.completed?)
      @employee_trip = employee_trips.upcoming.where.not(status: [:completed, :canceled]).not_dismissed.order(date: :asc).limit(1).first      

      if @employee_trip.blank? || (@employee_trip.present? and @employee_trip.date > Time.now + 4.hours)
        @completed_employee_trip = employee_trips.joins(:trip, :trip_route).completed
          .where('is_rating_screen_shown = false or is_still_on_board_screen_shown = false')
          .where('trip_routes.completed_date > ?', Time.now - 4.hours)
          .order('trips.start_date DESC, employee_trips.date DESC').limit(1).first
      end
    end

    @completed_employee_trip
  end

  # Get first upcoming employee trip
  def closest_employee_trip
    @employee_trip = employee_trips.where(status: :current).not_dismissed.order(date: :desc).limit(1).first
    if @employee_trip.blank? || (@employee_trip.trip_route.present? && @employee_trip.trip_route.completed?)
      @employee_trip = employee_trips.upcoming.where.not(status: [:completed, :canceled]).not_dismissed.order(date: :asc).limit(1).first
    end
    @employee_trip
  end  

  def home_address_location
    [ home_address_latitude, home_address_longitude ]
  end

  def nodal_address_location
    [ nodal_address_latitude, nodal_address_longitude ]
  end

  def address_with_id
    {
        :id  => id,
        :lat => home_address_latitude,
        :lng => home_address_longitude
    }
  end

  def call_operator(user_id)
    @user = User.employee.where(id: user_id).first
    @user_employer = User.employer.order('last_active_time DESC').first
    if @user.present?
      make_call(:From => self.site.phone, :To => @user.phone, :CallerId => ENV['EXOTEL_CALLER_ID'], :CallType => 'trans')
    end
  end

  def pick_up_address
    if self.bus_travel? && !self.bus_trip_route.blank?
      self.bus_trip_route&.stop_name
    else
      self.home_address
    end
  end

  def pick_up_lat_lng
    if self.bus_travel? && !self.bus_trip_route.blank?
      lat, lng = self.bus_trip_route&.stop_latitude, self.bus_trip_route&.stop_longitude
    else
      lat, lng = self.home_address_latitude, self.home_address_longitude
    end
    {lat: lat, lng: lng}
  end

  protected

  # Update home address coordinates on every save
  def set_home_address_coordinates
    self.home_address_latitude = nil
    self.home_address_longitude = nil

    # Geocoding an address
    results = home_address.present? ? GoogleService.new.geocode(home_address).first : nil

    unless results.nil? || ! results.key?(:geometry)
      coordinates = results[:geometry][:location]
      self.home_address_latitude = coordinates[:lat]
      self.home_address_longitude = coordinates[:lng]
      #update the geohash here
      self.geohash = GeoHash.encode(self.home_address_latitude.to_f, self.home_address_longitude.to_f, 12)
    end

  end

  # Set distance to site from home
  def calculate_distance_to_site
    self.distance_to_site = nil

    if site && home_address_location.any?
      distance_matrix = GoogleService.new.distance_matrix(home_address_location, site.location, mode: 'driving')
      self.geohash = GeoHash.encode(self.home_address_latitude.to_f, self.home_address_longitude.to_f, 12)

      if distance_matrix[:status] == 'OK'
        first_route = distance_matrix[:rows].first[:elements].first
        self.distance_to_site = first_route[:distance][:value].to_i if first_route[:status] == 'OK'

        update_employee_trips_site
      end

    end
  end

  def update_employee_trips_site
    @employee_trips = EmployeeTrip.where(status: :upcoming).where(employee: self).includes(:employee_trip_issues, :site)
    # Fetch all upcoming trips of the employee
    @employee_trips.each do |employee_trip|
      employee_trip.update!(:site => site, :zone => nil, :is_clustered => false, :cluster_error => nil)
    end
  end

  def home_address_location_calculated
    if home_address_latitude.blank? || home_address_longitude.blank?
      errors.add(:home_address, 'not found on Google Maps. Please use valid home address.')
    end
  end

  def distance_to_site_calculated
    if distance_to_site.blank?
      errors.add(:home_address, 'unable to calculate distance from home to site, please use valid address')
    end
  end

  def create_schedule
    7.times{ |n| self.employee_schedules << EmployeeSchedule.new(:day => n)}
  end

  def check_if_bus_travel_changed
    @employee_trips = EmployeeTrip.where(status: :upcoming).where(employee: self).includes(:employee_trip_issues)
    
    # Fetch all upcoming trips of the employee
    @employee_trips.each do |employee_trip|
      employee_trip.update!(:bus_rider => bus_travel)
    end
  end

  def make_call(params)
    HTTParty.post(URI.escape("https://#{ENV['EXOTEL_SID']}:#{ENV['EXOTEL_TOKEN']}@twilix.exotel.in/v1/Accounts/#{ENV['EXOTEL_SID']}/Calls/connect"),
    {
      :query => params,
      :body => params
    })
  end
end
