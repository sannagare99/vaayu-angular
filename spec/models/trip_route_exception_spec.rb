require 'rails_helper'

describe TripRouteException, type: :model do
  let(:trip) { FactoryGirl.create(:trip, employees_num: 1)}
  let(:trip_route) { trip.trip_routes.first }

  let(:trip_route_exception) { trip_route.trip_route_exceptions.create( exception_type: :employee_no_show, date: Time.now ) }

  subject { trip_route_exception }

  it { should belong_to(:trip_route) }

  context 'AASM state transitions' do
    context '#resolved!' do
      it 'should set resolved date' do
        expect { trip_route_exception.resolved! }.to change { trip_route_exception.resolved_date }.from(nil).to(Time)
      end
    end

    context '#resolved_by_operator!' do
      it 'should set resolved date' do
        expect { trip_route_exception.resolved_by_operator! }.to change { trip_route_exception.resolved_date }.from(nil).to(Time)
      end
      it 'should send push notification to driver' do
        expect(PushNotificationWorker).to receive(:perform_async).with(
            trip.driver.user_id, :operator_resolved_exception, {
            trip_id: trip_route.trip_id,
            trip_route_exception_id: trip_route_exception.id,
            trip_route_id: trip_route.id,
            data:{
                trip_id: trip_route.trip_id,
                trip_route_exception_id: trip_route_exception.id,
                trip_route_id: trip_route.id,
                push_type: :operator_resolved_exception
            }
        })
        trip_route_exception.resolved_by_operator!
      end

      it 'should set trip route as missed', pending_refactoring: true do
        expect { trip_route_exception.resolved_by_operator! }.to change { trip_route.reload.status }.to('missed')
      end
    end
  end
end
