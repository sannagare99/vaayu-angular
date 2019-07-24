describe API::V1::TripsController, type: :controller do
  before do
    allow_any_instance_of(GoogleMapsService::Client)
        .to receive(:directions)
                .and_return([
                                {
                                    waypoint_order: [0],
                                    legs: [
                                        { end_location: { value: 12 }, start_location: { value: 12.34 }, duration_in_traffic: { value: 10 }, distance: { value: 20 } },
                                        { end_location: { value: 11 }, start_location: { value: 11.22 }, duration_in_traffic: { value: 20 }, distance: { value: 30 } }
                                    ]
                                }
                            ])
  end
  render_views
  let(:address_generator) { RandomData::Address.new }
  let(:address) { address_generator.generate }
  let(:site) { FactoryGirl.create(:site, address: address_generator.generate) }
  let(:trip_date) { Date.today }
  let(:employee) { FactoryGirl.create(:employee, home_address: address, site: site) }
  let(:other_employee) { FactoryGirl.create(:employee, home_address: address_generator.generate) }
  let(:employee_trip) { FactoryGirl.create(:employee_trip, employee: employee, date: trip_date, rating: 3) }
  let(:other_employee_trip) { FactoryGirl.create(:employee_trip, employee: other_employee, date: trip_date) }


  let!(:trip) { FactoryGirl.create( :trip,
                                    scheduled_date: trip_date,
                                    planned_date:  Date.tomorrow,
                                    scheduled_approximate_duration: 10,
                                    planned_approximate_duration: 30,
                                    employee_trips: [employee_trip, other_employee_trip])

  }

  let(:trip_route) { trip.trip_routes.first }
  let(:driver) { trip.driver.user }
  let!(:driver2) { FactoryGirl.create(:driver) }
  let(:operator) { FactoryGirl.create(:operator) }

  let(:request_params) { { params: { id: trip.id }, format: :json } }
  let(:request_params_with_trip_routes) { { params: { id: trip.id, trip_routes: trip_route.id, lat: 12.345678, lng: 11.223344 }, format: :json } }
  let(:request_params_with_coords) { { params: { id: trip.id, lat: 12.345678, lng: 11.223344 }, format: :json } }


  describe 'GET show' do
    context 'authorized user' do
      context 'response validity checks' do
        before do
          request.headers.merge! driver.create_new_auth_token
          get :show, request_params
        end

        it { is_expected.to respond_with :ok }

        it 'should return  trip' do
          expect(response).to match_response_schema('trip')
        end
      end

      context 'trip not found' do
        before do
          request.headers.merge! driver.create_new_auth_token
          get :show, params: { id: 0 }, format: :json
        end

        it { is_expected.to respond_with :not_found }

        it 'should return valid error messages' do
          expect(response).to match_response_schema('errors')
        end
      end

      context 'unauthorized user' do
        before do
          request.headers.merge! operator.user.create_new_auth_token
          get :show, request_params
        end

        it { is_expected.to respond_with :forbidden }

        it 'should return valid error messages' do
          expect(response).to match_response_schema('errors')
        end
      end
    end
  end

  describe 'GET #start' do
    before do
      request.headers.merge! driver.create_new_auth_token
    end
    it 'should update route' do
      expect {
        get :start, request_params_with_coords
      }.to change { trip.reload.start_location }.to( lat: 12.345678, lng: 11.223344 )
    end

    it 'should not update route' do
      expect {
        get :start, request_params
      }.to_not change { trip.reload.start_location }
    end

    context 'start trip' do
      before do
        trip.status = 'assigned'
        trip.save
        get :start, request_params
      end

      it { is_expected.to respond_with :ok }

      it 'should start trip' do
        expect(trip.reload.status).to eq('active')
      end
    end

    context 'do not start trip' do
      before do
        get :start, request_params
      end

      it { is_expected.to respond_with 422 }

      it 'should not start trip' do
        expect{subject}.to_not change(trip, :status)
      end

      it 'should return valid error messages' do
        expect(response).to match_response_schema('errors')
      end
    end

  end

  describe 'GET #decline_trip_request' do

    context 'unauthorized user' do
      before do
        get :decline_trip_request, request_params
      end
      it { is_expected.to respond_with 401 }

      it 'should return valid error messages' do
        expect(JSON.parse(response.body)).to eq({"errors" => ["You need to sign in or sign up before continuing."]})
      end
    end
    context 'authorized user' do
      context 'trip without driver' do
        before do
          request.headers.merge! driver.create_new_auth_token
          trip.driver = nil
          trip.save
          get :decline_trip_request, request_params
        end

        it { is_expected.to respond_with 422 }
        it 'should return valid error messages' do
          expect(response).to match_response_schema('errors')
        end
      end
      context 'trip.driver != current_user' do
        before do
          request.headers.merge! driver.create_new_auth_token
          trip.driver = driver2
          trip.save
          get :decline_trip_request, request_params
        end

        it { is_expected.to respond_with 422 }
        it 'should return valid error messages' do
          expect(response).to match_response_schema('errors')
        end
      end

      context 'trip has driver & trip.driver == current_user' do
        before do
          request.headers.merge! driver.create_new_auth_token
        end
        context 'do not decline trip request' do
          before do
            allow_any_instance_of(Trip).to receive(:assign_request_declined!).and_return(false)
            get :decline_trip_request, request_params
          end

          it { is_expected.to respond_with 422 }
          it 'should return valid error messages' do
            expect(response).to match_response_schema('errors')
          end
        end

        context 'decline trip request' do
          before do
            allow_any_instance_of(Trip).to receive(:assign_request_declined!).and_return(true)
            get :decline_trip_request, request_params
          end

          it { is_expected.to respond_with :ok }
          it 'should return valid error messages' do
            expect(response).to match_response_schema('success')
          end
        end
      end

  end
  end

  describe 'GET #accept_trip_request' do

    context 'unauthorized user' do
      before do
        get :accept_trip_request, request_params
      end
      it { is_expected.to respond_with 401 }

      it 'should return valid error messages' do
        expect(JSON.parse(response.body)).to eq({"errors" => ["You need to sign in or sign up before continuing."]})
      end
    end
    context 'authorized user' do
      context 'trip without driver' do
        before do
          request.headers.merge! driver.create_new_auth_token
          trip.driver = nil
          trip.save
          get :accept_trip_request, request_params
        end

        it { is_expected.to respond_with 422 }
        it 'should return valid error messages' do
          expect(response).to match_response_schema('errors')
        end
      end
      context 'trip.driver != current_user' do
        before do
          request.headers.merge! driver.create_new_auth_token
          trip.driver = driver2
          trip.save
          get :accept_trip_request, request_params
        end

        it { is_expected.to respond_with 422 }
        it 'should return valid error messages' do
          expect(response).to match_response_schema('errors')
        end
      end

      context 'trip has driver & trip.driver == current_user' do
        before do
          request.headers.merge! driver.create_new_auth_token
        end
        context 'assign_request_accepted! false' do
          before do
            allow_any_instance_of(Trip).to receive(:assign_request_accepted!).and_return(false)
            get :accept_trip_request, request_params
          end

          it { is_expected.to respond_with 422 }
          it 'should return valid error messages' do
            expect(response).to match_response_schema('errors')
          end
        end

        context 'assign_request_accepted! true' do
          before do
            allow_any_instance_of(Trip).to receive(:assign_request_accepted!).and_return(true)
            get :accept_trip_request, request_params
          end

          it { is_expected.to respond_with :ok }
          it 'should return valid error messages' do
            expect(response).to match_response_schema('assigned_trip')
          end
        end
      end

    end
  end

  describe 'POST #driver_arrived' do
    context 'unauthorized user' do
      before do
        post :driver_arrived, request_params_with_trip_routes
      end
      it { is_expected.to respond_with 401 }
      it 'should return valid error messages' do
        expect(JSON.parse(response.body)).to eq({"errors" => ["You need to sign in or sign up before continuing."]})
      end
    end
    context 'authorized user' do
      before do
        request.headers.merge! driver.create_new_auth_token
        allow_any_instance_of(TripRoute).to receive(:scheduled_start_location).and_return({ lat: 12.34566, lng: 11.22333})
      end

      context 'response with errors' do
        before do
          allow_any_instance_of(TripRoute).to receive(:driver_arrived!).and_return(false)
          post :driver_arrived, request_params_with_trip_routes
        end
        it { is_expected.to respond_with 422 }
        it 'should return valid error messages' do
          expect(response).to match_response_schema('errors')
        end
      end

      context 'response without errors' do
        before do
          allow_any_instance_of(TripRoute).to receive(:driver_arrived!).and_return(true)
          post :driver_arrived, request_params_with_trip_routes
        end
        it { is_expected.to respond_with :ok }
        it 'should render show trip' do
          expect(response).to match_response_schema('trip')
        end
      end
    end
  end

  describe 'POST #on_board' do
    context 'unauthorized user' do
      before do
        post :on_board, request_params_with_trip_routes
      end
      it { is_expected.to respond_with 401 }
      it 'should return valid error messages' do
        expect(JSON.parse(response.body)).to eq({"errors" => ["You need to sign in or sign up before continuing."]})
      end
    end
    context 'authorized user' do
      before do
        request.headers.merge! driver.create_new_auth_token
      end

      context 'response with errors' do
        before do
          allow_any_instance_of(TripRoute).to receive(:boarded!).and_return(false)
          allow_any_instance_of(TripRoute).to receive(:scheduled_start_location).and_return({ lat: 12.34566, lng: 11.22333})
          post :on_board, request_params_with_trip_routes
        end
        it { is_expected.to respond_with 422 }
        it 'should return valid error messages' do
          expect(response).to match_response_schema('errors')
        end
      end

      context 'response without errors' do
        before do
          allow_any_instance_of(TripRoute).to receive(:boarded!).and_return(true)
          allow_any_instance_of(TripRoute).to receive(:scheduled_start_location).and_return({ lat: 12.34566, lng: 11.22333})
          post :on_board, request_params_with_trip_routes
        end
        it { is_expected.to respond_with :ok }
        it 'should render show trip' do
          expect(response).to match_response_schema('trip')
        end
      end
    end
  end

  describe 'POST #completed' do
    context 'unauthorized user' do
      before do
        post :completed, request_params_with_trip_routes
      end
      it { is_expected.to respond_with 401 }
      it 'should return valid error messages' do
        expect(JSON.parse(response.body)).to eq({"errors" => ["You need to sign in or sign up before continuing."]})
      end
    end
    context 'authorized user' do
      before do
        request.headers.merge! driver.create_new_auth_token
        allow_any_instance_of(TripRoute).to receive(:scheduled_start_location).and_return({ lat: 12.34566, lng: 11.22333})
      end

      context 'response with errors' do
        before do
          allow_any_instance_of(TripRoute).to receive(:completed!).and_return(false)

          post :completed, request_params_with_trip_routes
        end
        it { is_expected.to respond_with 422 }
        it 'should return valid error messages' do
          expect(response).to match_response_schema('errors')
        end
      end

      context 'response without errors' do
        before do
          trip_route.status = 'on_board'
          trip_route.save
          post :completed, request_params_with_trip_routes
        end
        it { is_expected.to respond_with :ok }
        it 'should update trip route status' do
          expect(trip_route.reload.status).to eq('completed')
        end
        it 'should render show trip' do
          expect(response).to match_response_schema('trip')
        end
      end
    end
  end

  context '#change_status_request_assigned' do
    before do
      request.headers.merge! driver.create_new_auth_token
      post :change_status_request_assigned, request_params_with_trip_routes
    end
    it 'should change trip status' do
      expect(trip.reload.status).to eq('assign_requested')
    end
  end

end