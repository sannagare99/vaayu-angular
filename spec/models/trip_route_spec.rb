require 'rails_helper'

describe TripRoute, type: :model do
  let(:trip) { FactoryGirl.create(:trip, employees_num: 2)}
  let(:trip_route) { trip.trip_routes.first }
  let(:trip_route_exception) { trip_route.trip_route_exceptions.create( exception_type: :employee_no_show, date: Time.now ) }
  let(:user) { trip.driver.user }
  let(:employee) { trip_route.employee }

  subject { trip_route }

  it { should belong_to(:employee_trip) }
  it { should belong_to(:trip) }
  it { should have_many(:trip_route_exceptions) }

  before do
    allow_any_instance_of(TripRoute).to receive(:make_call)

    allow_any_instance_of(GoogleMapsService::Client)
        .to receive_message_chain(:geocode, :first)
                .and_return({geometry: { location: {lat: 17.3980155, lng: 78.5932912} }})

    allow_any_instance_of(GoogleMapsService::Client)
        .to receive(:distance_matrix)
                .and_return({status: 'OK', rows: [elements: [distance: {value: 12345}, status: 'OK']]})
  end

  context 'AASM state transitions' do
    context '#driver_arrived!' do
      it 'should set driver arrived date' do
        expect { trip_route.driver_arrived! }.to change { trip_route.driver_arrived_date }.from(nil).to(Time)
      end

      context 'notifications' do

        before do
          # mute trip notifications
          allow_any_instance_of(Trip).to receive(:notify_employee_trips_changed)
        end

        after do
          trip_route.driver_arrived!
        end

        it 'should send push notification to employee' do
          expect(PushNotificationWorker).to receive(:perform_async).with(employee.user_id, :driver_arrived, anything)
          trip_route.driver_arrived!
        end

        it 'should not send any notifications if employee trip canceled' do
          expect(PushNotificationWorker).not_to receive(:perform_async).with(employee.user_id, :driver_arrived, anything)
          expect(SMSWorker).not_to receive(:perform_async)

          trip_route.cancel!
        end

        it 'should not send any notifications if employee trip missed' do
          expect(PushNotificationWorker).not_to receive(:perform_async).with(employee.user_id, :driver_arrived, anything)
          expect(SMSWorker).not_to receive(:perform_async)

          trip_route.update!(status: :missed)
        end

        it 'should send an SMS to employee that driver arrived' do
          expect(SMSWorker).to receive(:perform_async).with(employee.phone, any_args)
        end

        it 'should send an SMS to employee that driver arrived earlier' do
          # set driver arrived date to early one
          allow(trip_route).to receive(:approximate_driver_arrive_date).and_return(Time.now + 1.hour)

          expect(SMSWorker).to receive(:perform_async).with(employee.phone, anything, /early/)
        end

        it 'should notify trip employees about changes' do
          expect_any_instance_of(Trip).to receive(:notify_employee_trips_changed)
        end
      end

    end

    context '#boarded!' do
      before do
        # mute trip notifications
        allow_any_instance_of(Trip).to receive(:notify_employee_trips_changed)
        # set previous trip route status
        trip_route.status = :driver_arrived
      end

      after do
        trip_route.boarded!
      end

      context 'trip with one employee' do
        let(:trip) { FactoryGirl.create(:trip, employees_num: 1)}

        it 'should send push notification to employee' do
          expect(PushNotificationWorker).to receive(:perform_async).with(employee.user_id, :employee_on_board, anything).once
        end
      end

      it 'should send push notification to the next employee to be boarded' do
        next_employee = trip.trip_routes.second.employee
        expect(PushNotificationWorker).to receive(:perform_async).with(employee.user_id, :employee_on_board, anything)
        expect(PushNotificationWorker).to receive(:perform_async).with(next_employee.user_id, :next_pick_up, anything)
      end
      it 'should not send push notification to the next employee for check out trip' do
        trip.update!(trip_type: :check_out)
        next_employee = trip.trip_routes.second.employee
        expect(PushNotificationWorker).to receive(:perform_async).with(employee.user_id, :employee_on_board, anything)
        expect(PushNotificationWorker).not_to receive(:perform_async).with(next_employee.user_id, :next_pick_up, anything)
      end

      it 'should notify trip employees about changes' do
        expect_any_instance_of(Trip).to receive(:notify_employee_trips_changed)
      end

    end

    context '#completed!' do
      before do
        trip_route.status = :on_board
        trip.assign_request_accepted!
        trip.start_trip!
      end

      context 'trip of four' do
        let(:trip) { FactoryGirl.create(:trip, employees_num: 4) }
        let(:completed_statuses) { [:missed, :completed, :canceled] }

        before do
          # update all trip routes with different completed statuses
          trip.trip_routes.where('planned_route_order > 0').zip(completed_statuses) do |trip_route, status|
            trip_route.update!(status: status)
          end
        end

        it 'should complete trip if all other trip routes are completed, canceled or missed' do
          expect { trip_route.completed! }.to change {trip.reload.status }.to('completed')
        end

        it 'should mark all employee trips as completed' do
          trip_route.completed!
          non_completed_employee_trips = trip.employee_trips.where.not(status: completed_statuses)
          expect(non_completed_employee_trips).to be_empty
        end

        it 'should not complete trip if it was canceled' do
          trip.update!(status: :canceled)
          expect { trip_route.completed! }.not_to change { trip.reload.status }
        end
      end


      context 'notifications' do
        before do
          # mute trip notifications
          allow_any_instance_of(Trip).to receive(:notify_employee_trips_changed)
          allow_any_instance_of(Trip).to receive(:construct_trip_route_param)
        end

        after do
          trip_route.completed!
        end

        it 'should notify employee about completed trip' do
          expect(PushNotificationWorker).to receive(:perform_async).with(employee.user_id, :employee_trip_completed, anything)
        end
        it 'should notify next employee for check out trip' do
          trip.update!(trip_type: :check_out)
          next_employee = trip.trip_routes.second.employee

          expect(PushNotificationWorker).to receive(:perform_async).with(employee.user_id, :employee_trip_completed, anything)
          expect(PushNotificationWorker).to receive(:perform_async).with(next_employee.user_id, :next_drop, anything)
        end
      end

      it 'should notify trip employees about changes' do
        expect_any_instance_of(Trip).to receive(:notify_employee_trips_changed)
        trip_route.completed!
      end
    end

  end

end
