describe API::V1::TripRoutesController, type: :controller do
  let(:trip) { FactoryGirl.create(:trip, employees_num: 1)}
  let(:trip_route) { trip.trip_routes.first }
  let(:trip_route_exception) { trip_route.trip_route_exceptions.create( exception_type: :employee_no_show, date: Time.now ) }
  let(:user) { trip.driver.user }
  let!(:operator) { FactoryGirl.create(:operator) }

  let(:request_params) { { params: { id: trip_route.id }, format: :json } }
  let(:request_params_with_coords) { { params: { id: trip_route.id, lat: 12.345678, lng: 11.223344 }, format: :json } }

  before do
    allow_any_instance_of(TripRoute).to receive(:make_call)
  end

  describe 'GET #employee_no_show' do

    context 'authorized user' do
      context 'response validity checks' do
        render_views

        before do
          request.headers.merge! user.create_new_auth_token
          get :employee_no_show, request_params
        end

        it { is_expected.to respond_with :ok }

        it 'should return valid trip' do
          expect(response).to match_response_schema('trip')
        end
      end

      context 'behavioural checks' do
        before do
          allow(controller).to receive(:authorize!)
          allow(controller).to receive(:current_user).and_return(user)
        end

        it 'should create a new exception for trip route' do
          expect {
            get :employee_no_show, request_params
          }.to change { TripRouteException.count}.by(1)
        end

        it 'should initiate call employee user and operator' do
          expect_any_instance_of(TripRoute).to receive(:call_operator).once
          get :employee_no_show, request_params
        end

        it 'should check drivers geofence' do
          expect_any_instance_of(TripRoute).to receive(:check_no_show_geofence).with( '12.345678', '11.223344' ).once
          get :employee_no_show, request_params_with_coords
        end

        it 'should update missed location if it passed into params' do

          expect {
            get :employee_no_show, request_params_with_coords
          }.to change { trip_route.reload.missed_location }.to( lat: 12.345678, lng: 11.223344 )

        end

        it 'should create a new notification' do
          expect { get :employee_no_show, request_params }.to change { Notification.count }.by(1)
        end

      end

    end

    context 'unauthorized user' do
      before do
        request.headers.merge! operator.user.create_new_auth_token
        get :employee_no_show, request_params
      end

      it { is_expected.to respond_with :forbidden }

      it 'should return valid error messages' do
        expect(response).to match_response_schema('errors')
      end

    end


  end

  describe 'POST #initiate_call' do
    before do
      allow_any_instance_of(TripRoute).to receive(:make_call)
    end

    context 'authorized user' do
      # Should be refactored because the controller now does not render anything
      context 'response validity checks', pending_refactoring: true do
        render_views

        before do
          request.headers.merge! user.create_new_auth_token
          post :initiate_call, params: { call_type: 1, id: trip_route.id }, format: :json
        end

        it { is_expected.to respond_with :ok }

        it 'should return valid success response' do
          expect(response).to match_response_schema('success')
        end

      end

      context 'behavioural checks' do
        let(:employee) { trip_route.employee }
        before do
          allow(controller).to receive(:authorize!)
          allow(controller).to receive(:current_user).and_return(user)
        end

        it 'should connect a call from employee to driver if 0 passed', pending_refactoring: true do
          expect_any_instance_of(TripRoute).to receive(:make_call).with(:From => employee.phone, :To => user.phone, :CallerId => ENV['EXOTEL_CALLER_ID'], :CallType => 'trans')
          post :initiate_call, params: { call_type: 0, id: trip_route.id }, format: :json
        end

        it 'should connect a call from driver to employee if 1 passed' do
          expect_any_instance_of(TripRoute).to receive(:make_call).with(:From => user.phone, :To => employee.phone, :CallerId => ENV['EXOTEL_CALLER_ID'], :CallType => 'trans')
          post :initiate_call, params: { call_type: 0, id: trip_route.id }, format: :json
        end

      end

    end

    # @TODO - refactoring: add authorization to the methods
    context 'unauthorized user', pending_refactoring: true do
      before do
        request.headers.merge! operator.user.create_new_auth_token
        post :initiate_call, params: { call_type: 1, id: trip_route.id }, format: :json
      end

      it { is_expected.to respond_with :forbidden }

      it 'should return valid error messages' do
        expect(response).to match_response_schema('errors')
      end
    end

  end
end