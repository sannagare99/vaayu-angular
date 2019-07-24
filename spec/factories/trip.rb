FactoryGirl.define do
  factory :trip do
    transient do
      employees_num 0
    end
    start_location { { lat: 17.3980155, lng: 78.5932912} }

    driver
    site
    vehicle
    employee_trips { FactoryGirl.create_list(:employee_trip, employees_num) }

    factory :trip_with_guard do
      employee_trips { FactoryGirl.create_list(:employee_trip, employees_num) << FactoryGirl.create(:guard) }

      after(:create) do |trip|
        female_order = trip.check_in? ? 1 : trip.passengers - 1
        _ = trip.employees.joins(:trip_routes).where(trip_routes: { scheduled_route_order: female_order }).limit(1)
      end
    end
  end
end
