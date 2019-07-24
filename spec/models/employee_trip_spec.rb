require 'rails_helper'

describe EmployeeTrip, type: :model do
  before do
    allow_any_instance_of(Trip).to receive(:check_if_valid_trip).and_return('passed')
  end
  let(:address_generator) { RandomData::Address.new }
  let(:address) { address_generator.generate }
  let(:site) { FactoryGirl.create(:site, address: address_generator.generate ) }
  let(:employee) { FactoryGirl.create(:employee, home_address: address, site: site) }
  let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee) }
  subject { employee_trip }

  it { should belong_to(:employee) }
  it { should belong_to(:trip) }
  it { should have_one(:trip_route) }

  it 'should validate presence of date', pending_refactoring: true do
    should validate_presence_of(:date)
  end
  it 'should validate precense of employee', pending_refactoring: true do
    should validate_presence_of(:employee)
  end

  it 'rating cannot be < 0 or > 5' do
    should_not allow_values(0, -5, 10, 10000000, 1.5).for(:rating)
  end

  context "#employee_address" do
    it 'should have valid employee address' do
      expect(employee_trip.employee_address).to eq(address)
    end

    it 'should not be empty' do
      expect(employee_trip.employee_address).not_to be_empty
    end
  end


  context '= trip not assigned' do
    it 'trip should not exist ' do
      expect(employee_trip.trip).to eq(nil)
    end

    context '#trip_number' do
      it 'should have empty trip number' do
        expect(employee_trip.trip_number).to be_empty
      end
    end

    context '#eta' do
      it 'should return nil eta' do
        expect(employee_trip.eta).to be_nil
      end
    end

    context '#employee_full_name' do
      let(:user) { employee.user }

      it 'should consist of employee\'s first and last names' do
        expect(employee_trip.employee_full_name).to eq("#{user.f_name} #{user.l_name}")
      end

      it 'should not be empty' do
        expect(employee_trip.employee_full_name).not_to be_empty
      end
    end

    context '#destination' do
      it 'should not be empty' do
        expect(employee_trip.destination).not_to be_empty
      end

      context '= check in employee trip' do
        let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_in) }

        it 'should be an employee address' do
          expect(employee_trip.destination).to eq(employee.home_address)

        end
      end

      context '= check out employee trip' do
        let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_out) }

        it 'should be a site address' do
          expect(employee_trip.destination).to eq(site.address)
        end
      end
    end

    # @TODO move into one test after destination_lat and destination_lng methods merges (see EmployeeTrip::destination_lat todo)
    context '#destination_lat' do

      context '= check in employee trip' do
        let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_in) }

        it 'should not be empty' do
          expect(employee_trip.destination_lat).not_to be_blank
        end
        it 'should be valid latitude' do
          results = GoogleMapsService::Client.new.reverse_geocode([employee_trip.destination_lat, employee_trip.destination_lng]).first
          expect(results).not_to be_nil
          expect(results[:geometry]).not_to be_nil
        end
      end

      context '= check out employee trip' do
        let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_out) }

        it 'should not be empty' do
          expect(employee_trip.destination_lat).not_to be_blank
        end
        it 'should be valid latitude' do
          results = GoogleMapsService::Client.new.reverse_geocode([employee_trip.destination_lat, employee_trip.destination_lng]).first
          expect(results).not_to be_nil
          expect(results[:geometry]).not_to be_nil
        end
      end
    end

    # @TODO ^
    context '#destination_lng' do
      context '= check in employee trip' do
        let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_in) }

        it 'should not be empty' do
          expect(employee_trip.destination_lng).not_to be_blank
        end

        it 'should be valid longitude' do
          results = GoogleMapsService::Client.new.reverse_geocode([employee_trip.destination_lat, employee_trip.destination_lng]).first
          expect(results).not_to be_nil
          expect(results[:geometry]).not_to be_nil
        end
      end

      context '= check out employee trip' do
        let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, trip_type: :check_out) }

        it 'should not be empty' do
          expect(employee_trip.destination_lng).not_to be_blank
        end

        it 'should be valid longitude' do
          results = GoogleMapsService::Client.new.reverse_geocode([employee_trip.destination_lat, employee_trip.destination_lng]).first
          expect(results).not_to be_nil
          expect(results[:geometry]).not_to be_nil
        end
      end

    end

    context '#approximate_driver_arrive_date' do
      it 'should be unknown' do
        expect(employee_trip.approximate_driver_arrive_date).to be_nil
      end
    end

    context '#approximate_drop_off_date' do
      it 'should be unknown' do
        expect(employee_trip.approximate_drop_off_date).to be_nil
      end
    end

    context '#eta' do
      it 'should be unknown' do
        expect(employee_trip.eta).to be_nil
      end
    end

    context '#latest_trip_change_request' do
      let!(:trip_change_request) { TripChangeRequest.create(reason: :emergency, request_type: :cancel, employee_trip: employee_trip) }
      it 'should return latest trip change request' do
        expect(employee_trip.latest_trip_change_request).to eq(trip_change_request)
      end
    end
  end

  context '= trip assigned' do
    let(:trip_date) { Time.now + 5.hours }

    let(:other_employee) { FactoryGirl.create(:employee, home_address: address_generator.generate) }
    let(:other_employee_trip) { FactoryGirl.create(:employee_trip, employee: other_employee, date: trip_date) }
    let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, date: trip_date) }
    let!(:trip) { FactoryGirl.create(:trip, scheduled_date: trip_date, employee_trips: [employee_trip, other_employee_trip]) }

    it 'trip should not be nil' do
      expect(employee_trip.trip).not_to be_nil
    end

    it 'trip route should not be nil' do
      expect(employee_trip.trip_route).not_to be_nil
    end

    it 'trip eta should not be nil' do
      expect(employee_trip.trip_route.eta).not_to be_nil
    end

    context '#trip_number' do
      it 'should have correct trip number' do
        expect(employee_trip.trip_number).to eq("#{trip.scheduled_date.strftime("%m/%d/%Y")} - #{trip.id}")
      end
    end

    context '#approximate_driver_arrive_date' do
      it 'should be valid date/time' do
        expect(employee_trip.approximate_driver_arrive_date).to be_a_kind_of(Time)
      end

      it 'should be in a future', pending_refactoring: true do
        expect(employee_trip.approximate_driver_arrive_date).to be > Time.now
      end

      context '= check in trip' do
        let(:other_employee_trip) { FactoryGirl.create(:employee_trip, employee: other_employee, date: trip_date, trip_type: :check_in) }
        let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, date: trip_date, trip_type: :check_in) }
        let!(:trip) { FactoryGirl.create(:trip, scheduled_date: trip_date, employee_trips: [employee_trip, other_employee_trip]) }

        # @TODO: move this test to models/trip.rb when possible
        it 'created trip should be check in type' do
          expect(trip.check_in?).to be_truthy
        end

        it 'should be earlier than time to get out to work' do
          expect(employee_trip.approximate_driver_arrive_date).to be < employee_trip.date
        end
      end

      context '= check out trip' do
        let(:other_employee_trip) { FactoryGirl.create(:employee_trip, employee: other_employee, date: trip_date, trip_type: :check_out) }
        let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, date: trip_date, trip_type: :check_out) }
        let!(:trip) { FactoryGirl.create(:trip, scheduled_date: trip_date, employee_trips: [employee_trip, other_employee_trip]) }

        # @TODO: move this test to models/trip.rb when possible
        it 'created trip should be check out type' do
          expect(trip.check_out?).to be_truthy
        end

        it 'should be later than time to get out from work' do
          expect(employee_trip.approximate_driver_arrive_date).to be > employee_trip.date
        end
      end

    end

    context '#approximate_drop_off_date' do
      it 'should be valid date/time' do
        expect(employee_trip.approximate_drop_off_date).to be_a_kind_of(Time)
      end

      it 'should be in a future' do
        expect(employee_trip.approximate_drop_off_date).to be > Time.now
      end

      it 'should be later that pick up time', pending_refactoring: true do
        expect(employee_trip.approximate_drop_off_date).to be > employee_trip.approximate_driver_arrive_date
      end

      context '= check in trip' do
        let(:other_employee_trip) { FactoryGirl.create(:employee_trip, employee: other_employee, date: trip_date, trip_type: :check_in) }
        let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, date: trip_date, trip_type: :check_in) }
        let!(:trip) { FactoryGirl.create(:trip, scheduled_date: trip_date, employee_trips: [employee_trip, other_employee_trip]) }

        it 'should be earlier than time to be at work' do
          expect(employee_trip.approximate_drop_off_date).to be < employee_trip.date
        end
      end
    end

  end

  context '#rated?' do
    let(:employee_trip_with_rating) { FactoryGirl.create(:employee_trip, employee: employee, rating: 2) }

    it 'should return false if trip_employee has no rating' do
      expect(subject.rated?).to be_falsy
    end

    it 'should return true if trip_employee has rating' do
      expect(employee_trip_with_rating.rated?).to be_truthy
    end
  end

  context '#rate' do
    context 'when subject is rated' do
      before { allow(subject).to receive(:rated?).and_return(true) }

      it 'should return false' do
        expect(subject.rate(10)).to eql(false)
      end

      it 'should have error' do
        subject.rate(10)
        expect(subject.errors.full_messages).to eql(['The trip has already been rated'])
      end
    end

    context 'when trip_issues is present' do
      it 'employee trip issues cannot set when rating is more than 3' do
        subject.rate(rating: 5, trip_issues: [:not_timely, :unsafe] )
        expect(subject.employee_trip_issues).to be_empty
      end

      context 'when trip_issues is not Array' do
        it 'should return false' do
          expect(subject.rate(10, 3, 3)).to eql(false)
        end

        it 'should have error' do
          subject.rate(10, 3, 3)
          expect(subject.errors.full_messages).to eql(['Trip issues should be an array'])
        end
      end

      context 'when trip_issues is Array' do
        context 'when trip_issues is not in EmployeeTripIssue.issues' do
          it 'should return false' do
            expect(subject.rate(10, 3, [3])).to eql(false)
          end

          it 'should have error' do
            subject.rate(10, 3, [3])
            expect(subject.errors.full_messages).to eql(['3 is not a valid key for trip_issues'])
          end
        end

        context 'when trip_issues is in EmployeeTripIssue.issues' do
          it 'should return true' do
            expect(subject.rate(2, 3, ['dirty'])).to eql(true)
          end

          it 'should update attrs' do
            subject.rate(2, 3, ['dirty'])

            expect(subject.rating).to eq(2)
            expect(subject.rating_feedback).to eq('3')
            expect(subject.employee_trip_issues.first.issue).to eq('dirty')
          end
        end
      end
    end
  end


  context '#create_notify_about_missed' do
    let(:trip_date) { Time.now + 5.hours }
    let(:driver) { FactoryGirl.create(:driver) }
    let!(:trip) { FactoryGirl.create(:trip, scheduled_date: trip_date, employee_trips: [employee_trip], driver: driver) }

    it 'should change count of Notification from 0 to 1' do

      expect { subject.create_notify_about_missed }.to change { Notification.count }.from(0).to(1)
    end
  end

  context 'AASM state transitions' do
    let(:trip_date) { Time.now + 5.hours }
    let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, date: trip_date, trip_type: :check_in) }
    let!(:trip) { FactoryGirl.create(:trip, scheduled_date: trip_date, employee_trips: [employee_trip]) }

    context '#trip_canceled!' do
      it 'should cancel trip route after employee trip cancelled' do
        expect { employee_trip.trip_canceled! }.to change { employee_trip.trip_route.status }.to("canceled")
      end
    end

    context '#unassign!' do
      it 'should not belong to trip after unassign' do
        expect { employee_trip.unassign! }.to change { employee_trip.trip }.to(nil)
      end

      it 'should remove the employee trip from trip' do
        employee_trip.unassign!
        expect(trip.employee_trips.reload).not_to include(employee_trip)
      end

    end

    context '#approved_unassign!' do
      it 'should not belong to trip after unassign' do
        expect { employee_trip.approved_unassign! }.to change { employee_trip.trip }.to(nil)
      end

      it 'should remove the employee trip from trip' do
        employee_trip.approved_unassign!
        expect(trip.employee_trips.reload).not_to include(employee_trip)
      end
    end

    context '#employee_missed_trip!' do
      it 'should send notification about missed trip' do
        expect { employee_trip.employee_missed_trip! }.to change { Notification.count }.from(0).to(1)
      end
    end

  end

  describe ".trips_by_range" do
    it "should return employee trip based on input date range" do
      allow_any_instance_of(GoogleMapsService::Client).to receive(:geocode).and_return([{ geometry: { location: {lat: "28.451915", lng: "77.086861"}} }])
      date = Date.today
      et = FactoryGirl.create(:employee_trip, schedule_date: date)
      trips = EmployeeTrip.trips_by_range(et.employee, date.beginning_of_week.to_s, date.end_of_week.to_s)

      expect(trips.first.values.first.map { |x| x["schedule_date"] }.first).to eq Date.today
    end
  end
end