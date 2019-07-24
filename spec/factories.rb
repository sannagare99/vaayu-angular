# @TODO: figure out why it doesn't autoload from lib directory
require_relative '../lib/tests/random_address'
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :compliance_notification do
    driver_id 1
    vehicle_id 1
    message "MyString"
    status 1
    compliance_type 1
  end
  factory :checklist_item do
    checklist_id 1
    key "MyString"
    value false
    compliance_type 1
  end
  factory :checklist do
    vehicle_id 1
    driver_id 1
    status 1
  end
  factory :compliance do
    key "MyString"
    type 1
    compliance_type 1
  end
  factory :google_api_key do
    
  end
  factory :cluster_vehicle do
    
  end
  factory :device do
    device_id "LKAKFL-4J4K4"
    make "XiaoMI"
    model "5A"
    os "Android"
    os_version "8.0.1"
    status 1
  end
  factory :employee_cluster do
    date { Time.now }
  end
  factory :shift do
    name "Morning"
    start_time "08:00"
    end_time "17:00"
    status "active"
  end

  factory :shift_time do
    shift_manger_id 1
    shift_type "MyString"
    date "2017-09-08 08:49:32"
    schedule_date "2017-09-08 08:49:32"
    type ""
  end
  factory :employer_shift_manager do
    employee_company_id 1
  end
  factory :operator_shift_manager do
    logistics_company_id 1
    legal_name "MyString"
    pan "MyString"
    tan "MyString"
    business_type "MyString"
    service_tax_no "MyString"
    hq_address "MyString"
  end
  # Use this address generator to have proper addresses
  # that are in one city for Google maps API
  address_generator = RandomData::Address.new

  factory :notification do
    trip
    driver
    employee
    message 'driver_accepted_trip'
    receiver :operator
    resolved_status false
    new_notification true
  end

  factory :invoice_attachment do

  end
  factory :invoice do

  end
  factory :drivers_shift do

  end
  # ------- sequences --------------


  sequence(:pantan) { Devise.friendly_token.first(10) }
  sequence(:badge_number) { Devise.friendly_token.first(5).upcase }
  sequence(:aadhaar_number) { Devise.friendly_token.first(5).upcase }

  # -------------- factories -----------------

  factory :trip_change_request do
    request_type 1
    reason 1
    trip_type 0
    new_date "2016-11-02 15:53:01"
    approved 0
    employee nil
    employee_trip nil
  end

  factory :business_associate do |ba|
    admin_f_name { Faker::Name.first_name }
    admin_l_name { Faker::Name.first_name }
    pan { generate :pantan }
    tan { generate :pantan }
    name { Faker::Company.name }
    legal_name { Faker::Company.name }
    service_tax_no Devise.friendly_token.first(15)
    hq_address { address_generator.generate }
  end

  factory :logistics_company do
    name { Faker::Company.name }
  end

  factory :employee_company do
    name { Faker::Company.name }
    logistics_company
  end

  factory :site do
    name { Faker::Company.name }
    latitude 17.3980155
    longitude 78.5932912
    address { address_generator.generate }
    employee_company
  end

  factory :zone do
    name 1
    latitude 17.3980155
    longitude 78.5932912
  end

  factory :employee do
    employee_id 'ID233E2'
    #home_address { address_generator.generate }
    gender 1
    is_guard false

    after(:build) do |e|
        e.home_address, e.home_address_latitude, e.home_address_longitude = address_generator.generate_with_lat_long
    end

    after(:create) do |e|
      create(:user, entity: e, role: :employee)
    end

    employee_company
    site
    zone
  end

  factory :guard, parent: :employee do
    is_guard true
  end

  factory :employer do
    pan { generate :pantan }
    tan { generate :pantan }
    business_type "Private Limited"
    legal_name "Legal name"
    service_tax_no "BEEP6956ND00115"
    hq_address { address_generator.generate }

    after(:create) do |e|
      create(:user, entity: e, role: :employer)
    end

    employee_company
  end

  factory :driver do
    badge_number { generate :badge_number }
    aadhaar_number { generate :aadhaar_number }
    local_address { address_generator.generate }
    permanent_address { address_generator.generate }
    licence_number Devise.friendly_token.first(15).upcase
    licence_validity '08/08/2016'
    verified_by_police true
    status 'on_duty'

    after(:create) do |e|
      create(:user, entity: e, role: :driver)
    end

    logistics_company
    business_associate
    site
    vehicle
  end

  factory :operator do
    pan { generate :pantan }
    tan { generate :pantan }
    legal_name { |n| "Transorg India Private Limited #{n}" }
    business_type 'Private Limited'
    service_tax_no { Devise.friendly_token.first(15) }
    hq_address { address_generator.generate }

    after(:create) do |e|
      create(:user, entity: e, role: :operator)
    end

    logistics_company
  end

  factory :vehicle do
    plate_number { Faker::Internet.password(6).upcase }
    make 'Tesla'
    model 'Model X'
    colour { Faker::Color.color_name }
    rc_book_no 'some_rc_book_no'
    registration_date '10/12/2016'
    insurance_date '10/12/2016'
    permit_type 'Permanent'
    permit_validity_date '10/12/2020'

    seats 5
    make_year 2012
    device_id 'D189'
  end

  factory :employee_trip do
    trip_type :check_in
    date Time.now + 2.hours
    employee
  end

  factory :user do
    f_name { Faker::Name.first_name }
    l_name { Faker::Name.last_name }
    username { Faker::Internet.user_name("#{f_name} #{l_name}") }
    phone { Faker::PhoneNumber.cell_phone }
    password 'n3wnormal'
    email { "#{username}@n3wnormal.com" }
    role :employee
    # association :entity
  end

  factory :line_manager do
    employee_company
    after(:create) do |e|
      create(:user, entity: e, role: :line_manager)
    end
  end

  factory :transport_desk_manager do
    employee_company
    after(:create) do |e|
      create(:user, entity: e, role: :transport_desk_manager)
    end
  end

  factory :trip_route do

  end

  factory :trip_location do

  end

  factory :ingest_job do
    file { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'Ingest Excel Format.xlsx'), 'application/zip') }
    start_date { Date.today }

    ingest_type 'ingest_schedule'

    user
  end

  factory :ingest_manifest_job, class: IngestJob do
    file { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'ingest_manifest.xlsx'), 'application/zip') }

    ingest_type 'ingest_manifest'

    user
  end
end
