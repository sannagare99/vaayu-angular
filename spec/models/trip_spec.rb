describe Trip, type: :model do
  before do
    allow_any_instance_of(GoogleMapsService::Client)
        .to receive_message_chain(:geocode, :first)
                .and_return({geometry: { location: {lat: 100, lng: 200} }})

    allow_any_instance_of(GoogleMapsService::Client)
        .to receive(:distance_matrix)
                .and_return({status: 'OK', rows: [elements: [distance: {value: 123456}, status: 'OK']]})
    allow_any_instance_of(Trip).to receive(:create_or_update_route)

    allow_any_instance_of(GoogleMapsService::Client)
        .to receive(:directions)
                .and_return([
                                {
                                    waypoint_order: [0],
                                    legs: [
                                        { end_location: { value: 10 }, start_location: { value: 20 }, duration_in_traffic: { value: 100 }, distance: { value: 100 } },
                                        { end_location: { value: 35 }, start_location: { value: 40 }, duration_in_traffic: { value: 120 }, distance: { value: 170 } }
                                    ]
                                }])

    allow_any_instance_of(Trip).to receive(:check_if_valid_trip).and_call_original
  end

  def enable_guard_env
    env_enable_guard = ENV["ENALBE_GUARD_PROVISIONGING"]
    ENV["ENALBE_GUARD_PROVISIONGING"] = "true"
    yield
    ENV["ENALBE_GUARD_PROVISIONGING"] = env_enable_guard
  end

  Trip::DATATABLE_PREFIX.should == 'trip'
  Trip::ONBOARD_PASSENGER_TIME.should == 0
  Trip::TIME_TO_ARRIVE.should == 10
  Trip::DRIVER_ASSIGN_REQUEST_EXPIRATION.should == 3.minutes

  Trip::MAXIMUM_TRIP_DURATION.should == 90
  Trip::MAXIMUM_TRIP_DISTANCE.should == 45
  Trip::MAX_EMPLOYEES_IN_A_TRIP.should == 4

  Trip::MAX_DISTANCE_AWAY_IN_KM.should == 100.0
  Trip::RAD_PER_DEG.should == 0.017453293


  let(:address_generator) { RandomData::Address.new }
  let(:address) { address_generator.generate }
  let(:site) { FactoryGirl.create(:site, address: address_generator.generate) }
  let(:employee) { FactoryGirl.create(:employee, home_address: address, site: site) }
  let(:other_employee) { FactoryGirl.create(:employee, home_address: address_generator.generate) }
  let(:trip_date) { Date.today }
  let(:other_employee_trip) { FactoryGirl.create(:employee_trip, employee: other_employee, date: trip_date) }
  let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, date: trip_date, rating: 3) }

  let!(:trip) { FactoryGirl.create(:trip, scheduled_date: trip_date, planned_date:  Date.today + 1.week, scheduled_approximate_duration: 50, planned_approximate_duration: 50, employee_trips: [employee_trip, other_employee_trip]) }

  it { should belong_to(:site) }
  it { should belong_to(:vehicle) }
  it { should belong_to(:driver) }

  it { should have_many(:employee_trips) }
  it { should have_many(:employees).through(:employee_trips) }
  it { should have_many(:trip_routes).dependent(:destroy)}
  it { should have_many(:trip_route_exceptions).through(:trip_routes) }
  it { should have_many(:notifications).dependent(:destroy)}
  it { should have_many(:trip_location).dependent(:destroy)}

  context 'trip scopes' do
    before do
      @date = Time.now.beginning_of_day

      for i in 1..5
        test_date = Time.now.beginning_of_day + (i*10).hour
        empl_trip = FactoryGirl.create(:employee_trip, employee: employee, date: trip_date)
        FactoryGirl.create(:trip, scheduled_date: test_date, start_date: test_date, employee_trips: [empl_trip])
      end
    end

    it "applies get trip scope by some day" do
      expect(Trip.by_day(@date).count).to eq 3
    end

    it "applies get trip by period" do
      expect(Trip.by_period([@date, @date + 2.day]).count).to eq 4
    end
  end

  context 'before/after create' do
    let(:employee_trip_1) { FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_in) }
    let(:employee_trip_2) { FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_in) }
    let(:trip) { FactoryGirl.build(:trip, scheduled_date: trip_date, employee_trips: [employee_trip_1, employee_trip_2] )}

    before do

      allow_any_instance_of(GoogleMapsService::Client)
          .to receive(:directions)
                  .and_return([
                                  {
                                      waypoint_order: [0],
                                      legs: [
                                          { end_location: { value: 10 }, start_location: { value: 20 }, duration_in_traffic: { value: 100 }, distance: { value: 100 } },
                                          { end_location: { value: 35 }, start_location: { value: 40 }, duration_in_traffic: { value: 120 }, distance: { value: 170 } }
                                      ]
                                  }])
    end

    it 'should set trip type' do
      trip.save
      expect(trip.trip_type).to eq('check_in')
    end

    # context 'calculate trip date' do
    #   it 'should return right values if check_in? is true' do
    #     trip.save
    #     trip_start_date = trip.employee_trips.minimum(:date) - (4 + Trip::TIME_TO_ARRIVE).minutes
    #
    #     expect(trip.planned_approximate_duration).to eq(4)
    #     expect(trip.planned_approximate_distance).to eq(270)
    #     expect(trip.scheduled_approximate_duration).to eq(4)
    #     expect(trip.scheduled_approximate_distance).to eq(270)
    #     expect(trip.planned_date).to eq(trip_start_date)
    #     expect(trip.scheduled_date).to eq(trip_start_date)
    #   end
    #
    #   it 'should return right values if check_in? is false' do
    #     allow(trip).to receive(:check_in?).and_return(false)
    #     trip.save
    #     trip_start_date = trip.employee_trips.maximum(:date) + Trip::TIME_TO_ARRIVE.minutes
    #
    #     expect(trip.planned_approximate_duration).to eq(4)
    #     expect(trip.planned_approximate_distance).to eq(270)
    #     expect(trip.scheduled_approximate_duration).to eq(4)
    #     expect(trip.scheduled_approximate_distance).to eq(270)
    #     expect(trip.planned_date).to eq(trip_start_date)
    #     expect(trip.scheduled_date).to eq(trip_start_date)
    #   end
    # end

    context '#change employee trip status' do
      it 'should change status if employee_trip.canceled? is true' do
        allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(true)
        expect_any_instance_of(EmployeeTrip).to_not receive(:added_to_trip!)
        expect(PushNotificationWorker).to_not receive(:perform_async)

        trip.save
      end

      it 'should change status if employee_trip.canceled? is true' do
        allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(false)
        allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(false)

        expect(employee_trip_1).to receive(:added_to_trip!).once
        expect(employee_trip_2).to receive(:added_to_trip!).once
        expect(PushNotificationWorker).to receive(:perform_async).twice

        trip.save
      end
    end
  end

  context '#employees_are_not_in_trip_yet' do
    it 'should save trip' do
      empl_trip =  FactoryGirl.create(:employee_trip, employee: employee)
      trip = FactoryGirl.build( :trip, scheduled_date: trip_date, employee_trips: [empl_trip] )

      expect{trip.save}.to change(Trip, :count).by(1)
    end

    it 'should do not save trip' do
      trip = FactoryGirl.build(:trip, scheduled_date: trip_date, employee_trips: [employee_trip] )
      trip.save
      message = employee_trip.employee_full_name + " is already in trip"
      expect(trip.errors.messages[:base]).to eql([message])
    end
  end

  context '#employee_trip_ids_with_prefix' do
    it 'should remove string from employee trip ids' do
      # empl_trip = FactoryGirl.create(:employee_trip, employee: employee)
      # trip1 = FactoryGirl.build(:trip, scheduled_date: trip_date, employee_trips: [empl_trip] )
      # empl_trip.id = 'string_' + empl_trip.id
      # trip2 = FactoryGirl.build(:trip, scheduled_date: trip_date, employee_trips: [empl_trip] )
      # # trip = Trip.new(:employee_trip_ids_with_prefix=>params['ids'])
      # expect(trip1).to eq(trip2)
    end
  end

  context '#site_location' do
    it 'should return right site location' do
      expect(trip.site_location).to eq(trip.site.location)
    end
  end

  context '#site_location_hash' do
    it 'should return site location hash' do
      expect(trip.site_location_hash).to eq( {:lat => trip.site.latitude.to_f, :lng => trip.site.longitude.to_f})
    end
  end

  context '#passengers' do
    it 'should return passengers count' do
      expect(trip.passengers).to eq(trip.employee_trips.size)
    end
  end

  context '#next_pickup_date' do
    it 'should return next pickup date' do
      expect(trip.next_pickup_date).to eq(trip.scheduled_date)
    end
  end

  context '#approximate_trip_end_date' do
    it 'should return approximate trip end date' do
      appr_trip_end_date = trip.scheduled_date + trip.scheduled_approximate_duration.minutes
      expect(trip.approximate_trip_end_date).to eq(appr_trip_end_date)
    end
  end

  context '#planned_trip_end_date' do
    it 'should return planned_trip_end_date' do
      plan_tr_end_date = trip.planned_date + trip.planned_approximate_duration.minutes
      expect(trip.planned_trip_end_date).to eq(plan_tr_end_date)
    end
  end

  context '#average_rating' do
    let(:employee_trip_without_rating) { FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_in) }
    let(:trip_with_employee_trip_without_rating) { FactoryGirl.create(:trip, scheduled_date: trip_date, employee_trips: [employee_trip_without_rating] )}

    it 'should return nil if employee_trips empty' do
      expect(trip_with_employee_trip_without_rating.average_rating).to be_nil
    end

    it 'should return 3 if employee_trips present' do
      expect(trip.average_rating).to eql(3)
    end
  end

  context '#notify_employee_trips_changed' do
    before { trip.save }

    it 'should not send any notifications if employee_trip is canceled? or missed? are true' do
      allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(true)
      allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(true)

      expect(SMSWorker).to_not receive(:perform_async)
      expect(PushNotificationWorker).to_not receive(:perform_async)

      trip.notify_employee_trips_changed
    end

    it 'should send notifications if employee_trip is canceled?/missed?/completed? are false' do
      allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(false)
      allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(false)

      expect(PushNotificationWorker).to receive(:perform_async).exactly(4).times

      trip.notify_employee_trips_changed
    end
  end

  context '#notify_driver_about_ola_uber' do
    let(:trip_without_driver) { FactoryGirl.create(:trip, driver: nil, employee_trips: [FactoryGirl.create(:employee_trip, employee: employee, date: trip_date)]) }
    let(:trip_with_driver) { FactoryGirl.create(:trip, employee_trips: [FactoryGirl.create(:employee_trip, employee: employee, date: trip_date)]) }
    before do
      trip_without_driver.save
      trip_with_driver.save

    end

    it 'should do not send any notifications if trip has not driver' do
      expect(SMSWorker).to_not receive(:perform_async)
      expect(PushNotificationWorker).to_not receive(:perform_async)

      trip_without_driver.notify_driver_about_ola_uber
    end
    it 'should send notifications' do
      expect(SMSWorker).to receive(:perform_async)
      expect(PushNotificationWorker).to receive(:perform_async).once

      trip_with_driver.notify_driver_about_ola_uber
    end
  end

  context '#notify_employees_about_ola_uber' do
    before { trip.save }
    it 'should not send any notifications if employee_trip is canceled? or missed? are true' do
      allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(true)
      allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(true)

      expect(SMSWorker).to_not receive(:perform_async)
      expect(PushNotificationWorker).to_not receive(:perform_async)

      trip.notify_employees_about_ola_uber
    end

    it 'should send notifications if employee_trip is canceled?/missed?/completed? are false' do
      allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(false)
      allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(false)
      allow_any_instance_of(EmployeeTrip).to receive(:completed?).and_return(false)

      expect(PushNotificationWorker).to receive(:perform_async).exactly(2).times

      trip.notify_employees_about_ola_uber
    end

  end

  context '#is_valid_trip' do
    let(:trip) {  FactoryGirl.build(:trip, scheduled_date: trip_date, employee_trips: [employee_trip] ) }

    it 'should create trip and do not return error' do
      allow_any_instance_of(Trip).to receive(:check_if_valid_trip).and_return('passed')

      expect(trip.save).to be_truthy
      expect(trip.errors.full_messages).to eql([])
    end

    it 'should not create trip and do not return error' do
      allow_any_instance_of(Trip).to receive(:check_if_valid_trip).and_return('Roster exceeds Maximum Distance Exception')

      expect(trip.save).to be_falsey
      expect(trip.errors.full_messages).to eql(['Roster exceeds Maximum Distance Exception'])
    end
  end

  context '#check_if_valid_trip' do
    before do
      allow_any_instance_of(Trip).to receive(:check_if_valid_trip).and_call_original
    end
    let(:trip) {  FactoryGirl.build(:trip, scheduled_date: trip_date, employee_trips: [employee_trip] ) }
    let(:empl_trip_1) { FactoryGirl.create(:employee_trip, employee: employee) }
    let(:empl_trip_2) { FactoryGirl.create(:employee_trip, employee: employee) }
    let(:empl_trip_3) { FactoryGirl.create(:employee_trip, employee: employee) }
    let(:employee_female) { FactoryGirl.create(:employee, home_address: address, site: site, gender: 'female') }
    let(:employee_female1) { FactoryGirl.create(:employee, home_address: address, site: site, gender: 'female') }
    let(:employee_female2) { FactoryGirl.create(:employee, home_address: address, site: site, gender: 'female') }
    let(:employee_female3) { FactoryGirl.create(:employee, home_address: address, site: site, gender: 'female') }

    let(:empl_tr_female) { FactoryGirl.create(:employee_trip, employee: employee_female) }
    let(:empl_tr_female1) { FactoryGirl.create(:employee_trip, employee: employee_female1) }
    let(:empl_tr_female2) { FactoryGirl.create(:employee_trip, employee: employee_female2) }
    let(:empl_tr_female3) { FactoryGirl.create(:employee_trip, employee: employee_female3) }

    let(:trip_type) { 'check_in' }

    subject { trip.send(:check_if_valid_trip, [empl_trip_1.id, empl_trip_2], trip_type) }

    it "return 'passed'" do
      is_expected.to eql('passed')
    end

    it "return error 'Network error. Please try again.' " do
      allow_any_instance_of(GoogleMapsService::Client)
          .to receive(:directions).and_raise('Some network error')

      is_expected.to eql('Network error. Please try again.')
    end

    it "return error 'Roster exceeds Maximum Distance Exception'" do
      allow_any_instance_of(GoogleMapsService::Client)
        .to receive(:directions)
        .and_return([{
          waypoint_order: [0],
          legs: [
            { end_location: { value: 10 }, start_location: { value: 20 }, duration_in_traffic: { value: 100 }, distance: { value: 1000000 } },
            { end_location: { value: 35 }, start_location: { value: 40 }, duration_in_traffic: { value: 120 }, distance: { value: 1700000 } }
          ]
        }])

      is_expected.to eql('Roster exceeds Maximum Distance Exception')
    end

    it "return error 'Roster exceed Maximum Duration Exception'" do
      allow_any_instance_of(GoogleMapsService::Client)
        .to receive(:directions)
        .and_return([{
          waypoint_order: [0],
          legs: [
            { end_location: { value: 10 }, start_location: { value: 20 }, duration_in_traffic: { value: 1000000 }, distance: { value: 100 } },
            { end_location: { value: 35 }, start_location: { value: 40 }, duration_in_traffic: { value: 1200000 }, distance: { value: 170 } }
          ]
        }])

      is_expected.to eql('Roster exceed Maximum Duration Exception')
    end

    it "return error 'Reduce roster size since guard will be added because of female exception'" do
      enable_guard_env do
        allow_any_instance_of(Trip).to receive(:is_guard_required).and_return(false)
        allow_any_instance_of(GoogleMapsService::Client)
          .to receive(:directions)
          .and_return([{
            waypoint_order: [0],
            legs: [
              { end_location: { value: 10 }, start_location: { value: 20 }, duration_in_traffic: { value: 100 }, distance: { value: 100 } },
              { end_location: { value: 35 }, start_location: { value: 40 }, duration_in_traffic: { value: 120 }, distance: { value: 170 } }
            ]
          }])

        result = trip.send(:check_if_valid_trip, [empl_tr_female, empl_tr_female1.id, empl_tr_female2, empl_tr_female3], trip_type)

        expect(result).to eql('Reduce roster size since guard will be added because of female exception')
      end
    end

    context 'when no employee' do
      let(:empl_trip_1) { FactoryGirl.create(:employee_trip, employee: nil) }
      let(:empl_trip_2) { FactoryGirl.create(:employee_trip, employee: nil) }

      it "return error 'No Employees in Trip'" do
        is_expected.to eql('No Employees in Trip')
      end
    end

  end

  # @TODO – probably remove this tests
  context '#get_analytics_data', pending_refactoring: true do
    let(:trip) {  FactoryGirl.create(:trip, scheduled_date: trip_date, employee_trips: [employee_trip], planned_date: Date.today, trip_type: 'check_out' ) }
    let(:trip_route) {  FactoryGirl.create(:trip_route, employee_trip: employee_trip, trip: trip) }

    let(:results) do
      {
        :AcceptanceTime => trip.trip_accept_time,
        :CheckInLocation => {},
        :CheckInTime => nil,
        :DriverArrivedLocation => {},
        :DriverMooveNumber => trip.driver.phone,
        :DriverName => trip.driver.full_name,
        :DriverNumber => nil,
        :DropOffLocation => {},
        :DropOffTime => nil,
        :EmpId => employee.employee_id,
        :EmployeeMooveNumber => trip_route.employee_trip.employee.phone,
        :EmployeeName => trip_route.employee_trip.employee.full_name,
        :MLLTripId => "",
        :MissedLocation => {},
        :MooveManifestNumber => trip.scheduled_date.in_time_zone("Kolkata").strftime("%Y/%m/%d").to_s + '-' + trip.id.to_s,
        :NoShow => nil,
        :PanicRaised => "",
        :PickupLocationReachTime => nil,
        :PlannedApproximateDistance => nil,
        :PlannedApproximateDuration => nil,
        :PlannedDate => trip.planned_date.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s,
        :PlannedPickupTime => trip_route.approximate_driver_arrive_date,
        :RealDuration => nil,
        :Reason => "Reason",
        :Remarks => "",
        :RouteNo => nil,
        :ScheduledApproximateDistance => nil,
        :ScheduledApproximateDuration => nil,
        :ScheduledDate => trip.scheduled_date.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s,
        :Shift => "Shift Number",
        :Status => "not_started",
        :StillInCar => "",
        :TripAcceptTime => trip.trip_accept_time,
        :TripCompletedDate => nil,
        :TripCompletedTime => nil,
        :TripRequestExpiredDate => nil,
        :TripStartLocation => {:lat=>17.3980155, :lng=>78.5932912},
        :TripStartTime => nil,
        :VehicleNo => trip.vehicle.plate_number,
        :cancel_status => nil,
        :type => "check_out",
      }

    end

    it 'should return hash with data' do
      is_expected.to eql(results)
    end

    it 'should return hash with data when trip_route.missed?' do
      allow(trip_route).to receive(:missed?).and_return(true)

      is_expected.to eql(results.merge(:NoShow => 'no show'))
    end

    it 'should return hash with data when trip.assign_request_expired_date.present?' do
      allow(trip).to receive(:assign_request_expired_date).and_return(Date.today)

      is_expected.to eql(results.merge({:TripRequestExpiredDate => trip.assign_request_expired_date.in_time_zone("Kolkata").strftime("%m/%d/%Y %H:%M").to_s}))
    end
  end

  context 'return month/week/day from trip scheduled date' do
    it 'should return month from trip scheduled date' do
      expect(trip.month).to eq(trip.scheduled_date.strftime('%m'))
    end

    it 'should return week from trip scheduled date' do
      expect(trip.week).to eq(trip.scheduled_date.strftime('%W'))
    end

    it 'should return day from trip scheduled date' do
      expect(trip.day).to eq(trip.scheduled_date.strftime('%d'))
    end
  end

  context '#data' do
    it 'should return nill' do
      trip.start_date = nil
      expect(trip.data).to eq(nil)
    end

    it 'should return trip data' do
      trip.start_date = Date.tomorrow
      expect(trip.data).to eq(trip.start_date.strftime('%m/%d/%Y'))
    end
  end

  context '#scheduled_data' do
    it 'should return nill' do
      trip.scheduled_date = nil
      expect(trip.scheduled_data).to eq(nil)
    end

    it 'should return trip scheduled_data' do
      trip.scheduled_date = Date.tomorrow
      expect(trip.scheduled_data).to eq(trip.scheduled_date.strftime('%m/%d/%Y'))
    end
  end

  context '#set_trip_location' do
    it 'should create/save TripLocation' do
      expect{trip.set_trip_location({lat: 33, lng: 23}, 0, "0")}.to change(TripLocation, :count).by(1)
    end
  end

  context '#cancel_complete_trip' do

    # before { trip.save }
    # it 'should cancel employee_trip/trip_route' do
    #   allow_any_instance_of(EmployeeTrip.trip_route.status).to receive(:canceled?).and_return(false)
    #   allow_any_instance_of(EmployeeTrip.trip_route.status).to receive(:missed?).and_return(false)
    #   allow_any_instance_of(EmployeeTrip.trip_route.status).to receive(:completed?).and_return(false)
    #
    # end
  end

  context '#notify_employee_driver_trip_exception' do
    before { trip.save }

    it 'should not send any notifications if employee_trip is canceled? or missed? or completed? are true' do
      allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(true)
      allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(true)
      allow_any_instance_of(EmployeeTrip).to receive(:completed?).and_return(true)

      expect(PushNotificationWorker).to_not receive(:perform_async)
      trip.notify_employee_driver_trip_exception
    end

    it 'should send notifications if employee_trip is canceled? or missed? or completed? are false' do
      allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(false)
      allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(false)
      allow_any_instance_of(EmployeeTrip).to receive(:completed?).and_return(false)

      expect(PushNotificationWorker).to receive(:perform_async).exactly(2).times
      trip.notify_employee_driver_trip_exception
    end
  end

  context '#female_filter_results' do
    trip_date = DateTime.tomorrow.end_of_day.utc - 3.hour
    let(:employee_female) { FactoryGirl.create(:employee, home_address: address, site: site, gender: 'female') }
    let(:employee_female1) { FactoryGirl.create(:employee, home_address: address, site: site, gender: 'female') }
    let(:employee_male) { FactoryGirl.create(:employee, home_address: address, site: site, gender: 'male') }

    let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee_female, date: trip_date) }
    let(:employee_trip1) { FactoryGirl.create(:employee_trip, employee: employee_female1, date: trip_date) }
    let(:employee_trip2) { FactoryGirl.create(:employee_trip, employee: employee_male, date: trip_date) }

    let!(:trip) { FactoryGirl.create(:trip, scheduled_date: trip_date, scheduled_approximate_duration: 50, planned_approximate_duration: 50, employee_trips: [employee_trip, employee_trip1, employee_trip2]) }

    it 'should reorder employee trips' do
      expect(trip.send(:female_filter_results)).to eq([employee_trip2, employee_trip, employee_trip1])
    end

  end

  context '#update_trip_distance_duration' do
    let!(:trip_route) {  FactoryGirl.create(:trip_route, employee_trip: employee_trip, trip: trip, scheduled_distance: 70, scheduled_duration: 30, scheduled_start_location: {:lat=>17.3980155, :lng=>78.5932912}) }
    it 'should update trip attr' do
      expect{trip.send(:update_trip_distance_duration)}.to change(trip, :scheduled_approximate_duration)
      trip.scheduled_approximate_distance = 0
      expect{trip.send(:update_trip_distance_duration)}.to change(trip, :scheduled_approximate_distance)
      trip.scheduled_date = 0
      expect{trip.send(:update_trip_distance_duration)}.to change(trip, :scheduled_date)
    end

    it ' should not update trip attrs when employee_trips not exist' do
      allow_any_instance_of(Trip).to receive(:employee_trips).and_return([])
      expect{trip.send(:update_trip_distance_duration)}.to_not change(trip, :scheduled_approximate_duration)
      expect{trip.send(:update_trip_distance_duration)}.to_not change(trip, :scheduled_approximate_distance)
      expect{trip.send(:update_trip_distance_duration)}.to_not change(trip, :scheduled_date)
    end
  end

  context '#enqueue_request_expiration_job' do
    it 'should add to queue AutoSendReAssignmentPush && AutoRejectManifestWorker and update trip.assign_request_expired_date' do
      expect{trip.send(:enqueue_request_expiration_job)}.to change(trip, :assign_request_expired_date)
      expect(AutoSendReAssignmentPush).to receive(:perform_at).twice
      expect(AutoRejectManifestWorker).to receive(:perform_at)

      trip.send(:enqueue_request_expiration_job)
    end
  end

  context '#enqueue_request_restart_expiration_job' do
    it 'should add to queue AutoRejectManifestWorker && update trip.assign_request_expired_date' do
      expect{trip.send(:enqueue_request_restart_expiration_job)}.to change(trip, :assign_request_expired_date)
      expect(AutoRejectManifestWorker).to receive(:perform_at).with(trip.assign_request_expired_date,trip.id, trip.driver.id)

      trip.send(:enqueue_request_restart_expiration_job)
    end
  end

  context '#notify_driver_about_assignment' do
    it 'should send notifications' do
      allow_any_instance_of(Trip).to receive(:scheduled_approximate_distance).and_return(50)

      expect(SMSWorker).to receive(:perform_async)
      expect(PushNotificationWorker).to receive(:perform_async)
        .with(trip.driver.user_id, :driver_new_trip_assignment, {
            trip_id: trip.id,
            status: trip.status,
            trip_type: trip.trip_type,
            passengers: trip.passengers,
            approximate_duration: trip.scheduled_approximate_duration,
            approximate_distance: trip.scheduled_approximate_distance,
            date: trip.scheduled_date.to_i,
            assign_request_expired_date: trip.assign_request_expired_date.to_i,
            data: { push_type: :driver_new_trip_assignment }
        })

      trip.send(:notify_driver_about_assignment)
    end
  end

  context '#notify_driver_about_unassignment' do
    it 'should not send notifications when trip.driver == nil ' do
      allow_any_instance_of(Trip).to receive(:driver).and_return(nil)

      expect(PushNotificationWorker).to_not receive(:perform_async)
      trip.send(:notify_driver_about_unassignment)
    end

    it 'should send notifications' do
      expect(PushNotificationWorker).to receive(:perform_async).with(trip.driver.user_id, :driver_new_trip_unassignment, {driver_id: trip.driver.user_id, data: {
          driver_id: trip.driver.user_id,
          push_type: :driver_new_trip_unassignment}
      })
      trip.send(:notify_driver_about_unassignment)
    end
  end

  context '#notify_driver_trip_cancel' do
    it 'should not send notifications when trip.driver == nil ' do
      allow_any_instance_of(Trip).to receive(:driver).and_return(nil)

      expect(PushNotificationWorker).to_not receive(:perform_async)
      trip.send(:notify_driver_trip_cancel)
    end

    it 'should send notifications' do
      expect(PushNotificationWorker).to receive(:perform_async).with(trip.driver.user_id, :driver_cancel_trip, {driver_id: trip.driver.user_id, data: {
          driver_id: trip.driver.user_id,
          push_type: :driver_cancel_trip
      }})
      trip.send(:notify_driver_trip_cancel)
    end
  end

  context '#auto_resolve_notifications' do
    let!(:notification) {FactoryGirl.create(:notification, trip: trip, :driver => trip.driver, :message => 'trip_should_start', resolved_status: false) }
    it 'should update notification and change resolved_status to true' do
      trip.send(:auto_resolve_notifications)
      expect(notification.reload.resolved_status).to eq(true)
    end

  end

  context '#notify_employees_about_upcoming_trip' do
    context 'should not send any notification' do
      it 'when employee_trip canceled' do
        allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(true)
        expect(PushNotificationWorker).to_not receive(:perform_async)

        trip.send(:notify_employees_about_upcoming_trip)
      end
      it 'when employee_trip missed' do
        allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(true)
        expect(PushNotificationWorker).to_not receive(:perform_async)

        trip.send(:notify_employees_about_upcoming_trip)
      end
    end

    context 'should send notification' do
      it '' do
        allow_any_instance_of(EmployeeTrip).to receive(:approximate_driver_arrive_date).and_return(Time.now + 5.hours)

        expect(PushNotificationWorker).to receive(:perform_async).twice
        trip.send(:notify_employees_about_upcoming_trip)
      end
    end
  end

  context '#unassign_driver' do
    it 'should use method create! with params & send notification' do
      expect(Notification).to receive(:create!).with({
           :trip => trip,
           :driver => trip.driver,
           :message => 'not_accepted_manifest',
           :receiver => 0,
           :new_notification => true
      }).and_call_original
      trip.send(:unassign_driver)
    end

    it 'should update trip driver && assign_request_expired_date' do
      trip.send(:unassign_driver)

      expect(trip.driver).to eq(nil)
      expect(trip.assign_request_expired_date).to eq(nil)
    end

  end

  context '#create_notify_not_accepted_manifest' do
    it 'should use method create! with params & send notification' do
      expect(Notification).to receive(:create!).with({
           :trip => trip,
           :driver => trip.driver,
           :message => 'not_accepted_manifest',
           :receiver => 0,
           :resolved_status => false,
           :new_notification => true
      }).and_call_original
      trip.send(:create_notify_not_accepted_manifest)
    end
  end

  context '#create_notify_completed' do
    it 'should use method create! with params & send notification' do
      expect(Notification).to receive(:create!).with({
           :trip => trip,
           :driver => trip.driver,
           :message => 'trip_completed',
           :receiver => 2,
           :new_notification => true
       }).and_call_original
      trip.send(:create_notify_completed)
    end
  end

  context '#save_trip_accept_date' do
    it 'should update trip trip_accept_time' do
      expect{trip.send(:save_trip_accept_date)}.to change(trip, :trip_accept_time)
    end
  end

  context '#save_start_trip_data' do
    it 'should update trip start_date' do
      expect{trip.send(:save_start_trip_data)}.to change(trip, :start_date)
    end

    it 'should update create new notification' do
      expect{trip.send(:save_start_trip_data)}.to change(Notification, :count).by(1)
    end

  end

  context '#save_completed_trip_data' do
    let!(:trip) { FactoryGirl.create(:trip, scheduled_date: trip_date, start_date:  Time.now - 3.hour, employee_trips: [employee_trip, other_employee_trip]) }
    it 'should update trip start_date' do
      expect{trip.send(:save_completed_trip_data)}.to change(trip, :real_duration)
      trip.completed_date = nil
      expect{trip.send(:save_completed_trip_data)}.to change(trip, :completed_date)
    end
  end

  context '#set_employee_trips_as_started' do
    it 'should change employee trip status to current' do
      trip.send(:set_employee_trips_as_started)
      trip.employee_trips.each do |et|
        expect(et.status).to eq('current')
      end
    end
  end

  context '#resolve_trip_state_notifications' do
    let!(:notification) {FactoryGirl.create(:notification, trip: trip, :driver => trip.driver, :message => 'trip_should_start', resolved_status: false) }
    it 'should update notification and change resolved_status to true' do
      trip.send(:resolve_trip_state_notifications)
      expect(notification.reload.resolved_status).to eq(true)
    end
  end

  context '#add_driver_accepted_trip_notification' do
    it 'should change Notification count' do
      expect{trip.send(:add_driver_accepted_trip_notification)}.to change(Notification, :count).by(1)
    end

    it 'should use method create!' do
      expect(Notification).to receive(:create!).with({
         :trip => trip,
         :driver => trip.driver,
         :message => 'driver_accepted_trip',
         :receiver => :operator,
         :resolved_status => true,
         :new_notification => true
      }).and_call_original
      trip.send(:add_driver_accepted_trip_notification)
    end
  end

  context '#add_operator_assigned_trip_notification' do
    it 'should change Notification count' do
      expect{trip.send(:add_operator_assigned_trip_notification)}.to change(Notification, :count).by(1)
    end

    it 'should use method create!' do
      expect(Notification).to receive(:create!).with({
           :trip => trip,
           :driver => trip.driver,
           :message => 'operator_assigned_trip',
           :receiver => :operator,
           :resolved_status => true,
           :new_notification => true
       }).and_call_original
      trip.send(:add_operator_assigned_trip_notification)
    end
  end

  context '#notify_employees_trip_started' do
    context 'when trip check_in? true' do
      before do
        allow_any_instance_of(Trip).to receive(:check_in?).and_return(true)
      end

      context 'when trip_route present? true' do
        let!(:trip_route) {  FactoryGirl.create(:trip_route, employee_trip: employee_trip, trip: trip) }

        it 'should send PushNotificationWorker && SMSWorker ' do
          expect(SMSWorker).to receive(:perform_async)
          expect(PushNotificationWorker).to receive(:perform_async).twice

          trip.send(:notify_employees_trip_started)
        end

        it 'should not send second notification when employee_trip canceled' do
          allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(true)

          expect(SMSWorker).to receive(:perform_async)
          expect(PushNotificationWorker).to receive(:perform_async).once

          trip.send(:notify_employees_trip_started)
        end

        it 'should not send second notification when employee_trip.missed?' do
          allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(true)

          expect(SMSWorker).to receive(:perform_async)
          expect(PushNotificationWorker).to receive(:perform_async).once

          trip.send(:notify_employees_trip_started)
        end
      end

      context 'when trip_route present? false' do
        it 'should not send any notifications'do
          expect(SMSWorker).to_not receive(:perform_async)
          expect(PushNotificationWorker).to_not receive(:perform_async)
        end
      end
    end

    context 'when trip check_in? false' do
      before do
        allow_any_instance_of(Trip).to receive(:check_in?).and_return(false)
      end

      context 'when trip_route present? true' do
        let!(:trip_route) {  FactoryGirl.create(:trip_route, employee_trip: employee_trip, trip: trip) }

        it 'should send PushNotificationWorker && SMSWorker ' do
          expect(SMSWorker).to receive(:perform_async).twice
          expect(PushNotificationWorker).to receive(:perform_async).twice

          trip.send(:notify_employees_trip_started)
        end

        it 'should not send second notification when employee_trip canceled' do
          allow_any_instance_of(EmployeeTrip).to receive(:canceled?).and_return(true)

          expect(SMSWorker).to_not receive(:perform_async)
          expect(PushNotificationWorker).to_not receive(:perform_async)

          trip.send(:notify_employees_trip_started)
        end

        it 'should not send second notification when employee_trip.missed?' do
          allow_any_instance_of(EmployeeTrip).to receive(:missed?).and_return(true)

          expect(SMSWorker).to_not receive(:perform_async)
          expect(PushNotificationWorker).to_not receive(:perform_async)

          trip.send(:notify_employees_trip_started)
        end

      end

      context 'when trip_route present? false' do
        it 'should not send any notifications'do
          expect(SMSWorker).to_not receive(:perform_async)
          expect(PushNotificationWorker).to_not receive(:perform_async)
        end
      end

    end
  end

  context '#notify_if_female_in_trip' do
    it 'should create Notification' do
      enable_guard_env do
        allow_any_instance_of(Trip).to receive(:is_female_first_or_last_in_trip?).and_return(true)
        expect{trip.send(:notify_if_female_in_trip)}.to change(Notification, :count).by(1)
      end
    end
  end

  context '#haversine_distance' do
    it 'it should return distance in meters' do
      result = trip.send(:haversine_distance, 19.0974153, 72.8591881, 19.0973275, 72.8597071)
      expect(result.round(1)).to eq(55.4)
    end
  end

  context '#get_arrive_date_day' do
    it 'should return date' do
      result = trip.send(:get_arrive_date_day, Date.today + 1.week)
      expect(result).to eq(Date.today + 1.week)
    end
    it 'should return Today' do
      result = trip.send(:get_arrive_date_day, Date.today)
      expect(result).to eq('Today')
    end
    it 'should return Tomorrow' do
      result = trip.send(:get_arrive_date_day, Date.tomorrow)
      expect(result).to eq('Tomorrow')
    end
  end

end
