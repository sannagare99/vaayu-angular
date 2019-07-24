describe API::V1::TripRouteExceptionsController, type: :controller do

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

  let(:address_generator) { RandomData::Address.new }
  let(:address) { address_generator.generate }
  let(:site) { FactoryGirl.create(:site, address: address_generator.generate) }
  let(:trip) { FactoryGirl.create(:trip, employees_num: 1)}
  let(:trip_date) { Date.today }
  let(:employee) { FactoryGirl.create(:employee, home_address: address, site: site) }
  let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, date: trip_date, rating: 3) }
  let(:trip_route) {  FactoryGirl.create(:trip_route, employee_trip: employee_trip, trip: trip, scheduled_route_order: 1) }
  let(:trip_route_exception) { trip_route.trip_route_exceptions.create( exception_type: :employee_no_show, date: Time.now ) }
  let(:notification) { FactoryGirl.create(:notification, trip: trip, driver: driver.entity, message: trip_route_exception.exception_type, employee: employee.user.entity ) }
  let(:driver) { trip.driver.user }
  let(:operator) { FactoryGirl.create(:operator) }


  describe 'POST #resolve' do

    context 'authorized user' do
      context 'response validity checks' do
        render_views

        before do
          request.headers.merge! driver.create_new_auth_token
          post :resolve, params: { id: trip_route_exception.id }, format: :json
        end

        it { is_expected.to respond_with :ok }

        it 'should return valid trip for driver' do
          expect(response).to match_response_schema('trip')
        end

        it 'should return valid success message for employee', pending_refactoring: true do
          request.headers.merge! employee.create_new_auth_token
          post :resolve, params: { id: trip_route_exception.id }, format: :json

          expect(response).to match_response_schema('success')
        end
      end

      context 'behavioural checks' do
        before do
          allow(controller).to receive(:authorize!)
          allow(controller).to receive(:current_user).and_return(employee.user)
        end

        it 'should mark exception as resolved' do
          expect {
            post :resolve, params: { id: trip_route_exception.id }, format: :json
          }.to change { trip_route_exception.reload.status }.to('closed')
        end

        it 'should save resolved date' do
          expect {
            post :resolve, params: { id: trip_route_exception.id }, format: :json
          }.to change { trip_route_exception.reload.resolved_date }
        end

        it 'should mark as resolved related notification' do
          expect {
            post :resolve, params: { id: trip_route_exception.id }, format: :json
          }.to change { notification.reload.resolved_status }.to(true)
        end

      end

    end

    context 'unauthorized user' do
      before do
        request.headers.merge! operator.user.create_new_auth_token
        post :resolve, params: { id: trip_route_exception.id }, format: :json
      end

      it { is_expected.to respond_with :forbidden }

      it 'should return valid error messages' do
        expect(response).to match_response_schema('errors')
      end

    end

  end

end
