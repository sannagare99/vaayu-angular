describe Driver, type: :model do
  let!(:driver) { FactoryGirl.create(:driver) }
  subject { driver }

  context 'AASM events' do

    context '#go_on_duty!' do
      it 'cannot do on duty without a vehicle', pending_refactoring: true do
        driver.update!(vehicle: nil)

        expect(driver.go_on_duty!).to be_falsey
        expect(driver.errors.full_messages).to include('Driver cannot start shift without car assigned')
      end

      it "should start a driver's shift" do
        expect { driver.go_on_duty! }.to change { DriversShift.count }.by(1)
      end
    end

    context '#go_off_duty!' do
      before do
        driver.go_on_duty!
        driver.go_off_duty!
      end

      it 'should unassign a vehicle' do
        expect(driver.vehicle).to be_nil
      end

      it 'should close driver shift' do
        shift = driver.drivers_shifts.order(start_time: :desc).first
        expect(shift.end_time).not_to be_nil
        expect(shift.duration).not_to be_nil
      end
    end

    context '#go_on_leave!' do
      before do
        driver.go_on_duty!
        driver.go_on_leave!
      end

      it 'should unassign a vehicle' do
        expect(driver.vehicle).to be_nil
      end

      it 'should close driver shift' do
        last_shift = driver.drivers_shifts.order(start_time: :desc).first
        expect(last_shift.end_time).not_to be_nil
        expect(last_shift.duration).not_to be_nil
      end
    end
  end


  # Refactoring explanation:
  # the method's name tells us that it should return only unstarted trip
  # but actually it returns only active trips -> needs to be refactored
  context '#closest_unstarted_trip', pending_refactoring: true do
    let!(:closest_trip) { FactoryGirl.create(:trip, employee_trips: [FactoryGirl.build(:employee_trip, date: Time.now + 2.hours)], driver: driver)}
    let!(:other_trip) { FactoryGirl.create(:trip, employee_trips: [FactoryGirl.build(:employee_trip, date: Time.now + 2.hours)], driver: driver)}
    let!(:one_more_trip) { FactoryGirl.create(:trip, employee_trips: [FactoryGirl.build(:employee_trip, date: Time.now + 2.hours)], driver: driver)}

    it 'should return closest trip' do
      expect(driver.closest_unstarted_trip).to eq(closest_trip)
    end

    it 'should not return uber/ola trip' do
      closest_trip.book_ola_uber!
      closest_trip.update!(book_ola: true)

      expect(driver.closest_unstarted_trip).to eq(other_trip)
    end

    it 'should not return canceled trip' do
      closest_trip.cancel!
      expect(driver.closest_unstarted_trip).to eq(other_trip)
    end

    it 'should not return completed trip' do
      closest_trip.assign_request_accepted!
      closest_trip.start_trip!
      closest_trip.completed!

      expect(driver.closest_unstarted_trip).to eq(other_trip)
    end

    it 'should return active trip even than there is closer one unstarted' do
      other_trip.assign_request_accepted!
      other_trip.start_trip!

      expect(driver.closest_unstarted_trip).to eq(other_trip)
    end

    it 'should not return inactive trips later than today' do
      driver.trips.each{|t| t.update!(scheduled_date: Time.now - 1.day) }
      expect(driver.closest_unstarted_trip).to be_nil
    end

    it 'should return nil when driver has no trips' do
      driver.trips.destroy_all

      expect(driver.closest_unstarted_trip).to be_nil
    end
  end

  context '#attach_vehicle' do
    let(:free_vehicle) { FactoryGirl.create(:vehicle, plate_number: 'ZZZ0000')}
    let(:used_vehicle) { FactoryGirl.create(:vehicle, plate_number: 'ZZZ9999')}
    let!(:other_driver) { FactoryGirl.create(:driver, vehicle: used_vehicle)}

    it 'cannot attach vehicle that already in use' do
      expect(driver.attach_vehicle(used_vehicle)).to be_falsey
      expect(driver.vehicle).not_to eq(used_vehicle)
      expect(driver.errors.full_messages).to include('The vehicle is already in use')
    end

    it 'vehicle should be attached to a current driver' do
      expect(driver.attach_vehicle(free_vehicle)).to be_truthy
      expect(driver.vehicle).to eq(free_vehicle)
    end
  end
  context '#driver_trip_exception' do
    let!(:operator) { FactoryGirl.create(:operator) }

    context 'Connect a call between driver and operator when car brokes down' do
      after { driver.driver_trip_exception('Car Broke Down') }

      it 'should initiate the call from user to any operator' do
        expect(driver).to receive(:make_call).and_return(true)
      end

      it 'should initiate call to a default number when operator does not exist', pending_refactoring: true do
        Operator.destroy_all
        expect(driver).to receive(:make_call).and_return(true)
      end
    end

    context 'Send proper notifications' do
      before { allow(driver).to receive(:make_call).and_return(true) }

      it 'should send a notification' do
        expect{ driver.driver_trip_exception('Car Broke Down') }.to change { Notification.count }.by(1)
        expect{ driver.driver_trip_exception('On Leave') }.to change { Notification.count }.by(1)
        expect{ driver.driver_trip_exception('Other Reason') }.to change { Notification.count }.by(1)
      end

      it 'notification should have proper data' do
        driver.driver_trip_exception('On Leave')

        last_notification = Notification.last
        expect(last_notification.receiver).to eq('operator')
        expect(last_notification.driver).to eq(driver)
        expect(last_notification.resolved_status).to be_truthy
      end

      context 'trip created' do
        let(:employee_trip) { FactoryGirl.create(:employee_trip) }
        let!(:trip) { FactoryGirl.create(:trip, employee_trips: [ employee_trip ], driver: driver) }

        before { driver.driver_trip_exception('Car Broke Down') }

        it 'notification should contain trip data and have unresolved status' do
          allow_any_instance_of(Trip).to receive(:check_if_valid_trip).and_return('passed')
          last_notification = Notification.last

          expect(last_notification.trip).to eq(driver.trips.last)
          expect(last_notification.resolved_status).not_to be_truthy
        end
      end
    end
  end

  context "#checklist_status" do
    it "should return blank status" do
      
    end
  end

end