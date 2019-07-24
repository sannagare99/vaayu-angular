describe TripLocationsController, type: :controller do
  before do
    allow(controller).to receive(:authenticate_user!)
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
          }
        ])

  end

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
  let!(:trip_location1) { FactoryGirl.create(:trip_location, trip: trip, location: {:lat=>17.3980155, :lng=>78.5932912}, time: Time.now - 30.minutes)}
  let!(:trip_location2){ FactoryGirl.create(:trip_location, trip: trip, location: {:lat=>17.3980, :lng=>78.5942}, time: Time.now - 20.minutes)}

  describe '#index' do
    subject { JSON.parse(response.body) }
    it { expect(response).to be_success }
    date_format = "%Y-%m-%dT%H:%M:%S.%LZ"

    it 'should return JSON data with all trip_location records' do
      get :index, { id: trip.id, format: :json }
      is_expected.to eq([
          {
              'id' => trip_location1.id,
              'trip_id' => trip_location1.trip.id,
              'location' => {
                  'lat' => trip_location1.location[:lat],
                  'lng' => trip_location1.location[:lng]
              },
              'time' =>  trip_location1.time.strftime(date_format),
              'created_at' => trip_location1.created_at.strftime(date_format),
              'updated_at' => trip_location1.updated_at.strftime(date_format),
              'distance' => trip_location1.distance,
              'speed' => trip_location1.speed
          },
          {
              'id' => trip_location2.id,
              'trip_id' => trip_location2.trip.id,
              'location' => {
                  'lat' => trip_location2.location[:lat],
                  'lng' => trip_location2.location[:lng]
              },
              'time' => trip_location2.time.strftime(date_format),
              'created_at' => trip_location2.created_at.strftime(date_format),
              'updated_at' => trip_location2.updated_at.strftime(date_format),
              'distance' => trip_location2.distance,
              'speed' => trip_location2.speed
            }
      ])
    end

    it 'should return JSON data when trip start_date not blank' do
      allow_any_instance_of(Trip).to receive(:start_date).and_return(Time.now - 25.minutes)

      get :index, { id: trip.id, format: :json }
      is_expected.to eq([
          {
              'id' => trip_location2.id,
              'trip_id' => trip_location2.trip.id,
              'location' => {
                  'lat' => trip_location2.location[:lat],
                  'lng' => trip_location2.location[:lng]
              },
              'time' => trip_location2.time.strftime(date_format),
              'created_at' => trip_location2.created_at.strftime(date_format),
              'updated_at' => trip_location2.updated_at.strftime(date_format),
              'distance' => trip_location2.distance,
              'speed' => trip_location2.speed
          }
      ])
    end

    it 'should return JSON data when trip completed_date not blank' do
      allow_any_instance_of(Trip).to receive(:completed_date).and_return(Time.now - 25.minutes)

      get :index, { id: trip.id, format: :json }
      is_expected.to eq([
          {
              'id' => trip_location1.id,
              'trip_id' => trip_location1.trip.id,
              'location' => {
                  'lat' => trip_location1.location[:lat],
                  'lng' => trip_location1.location[:lng]
              },
              'time' => trip_location1.time.strftime(date_format),
              'created_at' => trip_location1.created_at.strftime(date_format),
              'updated_at' => trip_location1.updated_at.strftime(date_format),
              'distance' => trip_location1.distance,
              'speed' => trip_location1.speed
          }
      ])
    end
  end

end