BusinessAssociate.create!(
    admin_f_name: 'AdminFName',
    admin_l_name: 'AdminLName',
    name: 'BusinessAssociateName',
    pan: Devise.friendly_token.first(10),
    tan: Devise.friendly_token.first(10),
    legal_name: 'BA Legal Name',
    service_tax_no: Devise.friendly_token.first(15),
    hq_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002'
)

Zone.create! name: 1, latitude: '17.3980155', longitude: '78.5932912'

vehicle = Vehicle.create!(
    plate_number: 'CA12345AA',
    make: 'Tesla',
    model: 'Model X',
    colour: 'black',
    rc_book_no: 'some_rc_book_no',
    registration_date: '10/12/2016',
    insurance_date: '10/12/2016',
    permit_type: 'Permanent',
    permit_validity_date: '10/12/2020',
    seats: 4,
    make_year: 2012,
    device_id: 'D189'
)

Vehicle.create!(
    plate_number: 'CA54321AA',
    make: 'Tesla',
    model: 'Model S',
    colour: 'red',
    rc_book_no: 'some_other_rc_book_no',
    registration_date: '11/11/2016',
    insurance_date: '11/11/2016',
    permit_type: 'Permanent',
    permit_validity_date: '11/11/2020',
    seats: 4,
    make_year: 2015,
    device_id: 'D189X'
)

l_comp = LogisticsCompany.create! name:'Mahindra Logistics Limited'
e_comp = EmployeeCompany.create! name: 'PwC India Limited', logistics_company: l_comp
site = Site.create!(
    name: 'PwC - DLF Cyber City',
    latitude: '28.493719',
    longitude: '77.087908',
    address: 'GURGAON, HARYANA, 122002',
    employee_company: e_comp
)

operator = Operator.create!(
    pan: 'BKYPB4114M',
    tan: 'CLTPB4016Z',
    legal_name: 'Transorg India Private Limited',
    business_type: 'Private Limited',
    service_tax_no: 'BEEP6956ND00115',
    hq_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    logistics_company: l_comp
)
driver = Driver.create!(
    badge_number: 'EE444V43',
    aadhaar_number: '891234781111',
    local_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    permanent_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    licence_number: 'DL1234567893214',
    licence_validity: '08/08/2016',
    verified_by_police: true,
    logistics_company: l_comp,
    business_associate: BusinessAssociate.last,
    site: site,
    status: 'on_duty',
    vehicle: Vehicle.last
)

driver2 = Driver.create!(
    badge_number: 'B561332',
    aadhaar_number: '891234782222',
    local_address: 'Near vyapar kendra',
    permanent_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    licence_number: 'DL1234167893214',
    licence_validity: '08/08/2019',
    verified_by_police: true,
    logistics_company: l_comp,
    business_associate: BusinessAssociate.last,
    site: site,
    status: 'off_duty',
    vehicle: nil
)

driver3 = Driver.create!(
    badge_number: '123334',
    aadhaar_number: '891224783333',
    local_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    permanent_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    licence_number: 'DL1231567893214',
    licence_validity: '08/08/2020',
    verified_by_police: true,
    logistics_company: l_comp,
    business_associate: BusinessAssociate.last,
    site: site,
    status: 'off_duty',
    vehicle: nil
)

driver4 = Driver.create!(
    badge_number: '12333334',
    aadhaar_number: '891224704444',
    local_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    permanent_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    licence_number: 'DL1031567893214',
    licence_validity: '08/09/2011',
    verified_by_police: true,
    logistics_company: l_comp,
    business_associate: BusinessAssociate.last,
    site: site,
    status: 'off_duty',
    vehicle: nil
)

driver5 = Driver.create!(
    badge_number: '12313334',
    aadhaar_number: '891224705555',
    local_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    permanent_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    licence_number: 'DL1031567893214',
    licence_validity: '11/11/2017',
    verified_by_police: true,
    logistics_company: l_comp,
    business_associate: BusinessAssociate.last,
    site: site,
    status: 'off_duty',
    vehicle: nil
)

driver6 = Driver.create!(
    badge_number: '12326666',
    aadhaar_number: '891224708256',
    local_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    permanent_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002',
    licence_number: 'DL1031566693214',
    licence_validity: '11/11/2017',
    verified_by_police: true,
    logistics_company: l_comp,
    business_associate: BusinessAssociate.last,
    site: site,
    status: 'off_duty',
    vehicle: nil
)

employer = Employer.create!(
    legal_name: 'Legal name',
    employee_company: e_comp,
    pan: 'BKYPB4114M',
    tan: 'CLTPB4016Z',
    business_type: 'Private Limited',
    service_tax_no: 'BEEP6956ND00115',
    hq_address: '#2, 2ND CROSS, GHATTA GAON, NEAR LIC BUILDING, GURGAON, HARYANA, 122002'
)
employee = Employee.create!(
    employee_id: '321432',
    employee_company: e_comp,
    home_address: '1993 Block C, Sushant Lok Phase I, Sector 43 Gurugram, Haryana 122022',
    gender: 1,
    site: site,
    zone: Zone.last,
    home_address_latitude: '17.3980155',
    home_address_longitude: '78.5932912'
)

employee2 = Employee.create!(
    employee_id: '3278165',
    employee_company: e_comp,
    home_address: 'C-, 1219, Sushant Lok Phase I, Block C, Sushant Lok Phase I, Sector 43, Gurugram, Haryana 122022',
    gender: 0,
    site: site,
    zone: Zone.last,
    home_address_latitude: '17.3980155',
    home_address_longitude: '78.5932912'
)

employee3 = Employee.create!(
    employee_id: '651432',
    employee_company: e_comp,
    # @TODO: find out why original address does not work now
    # home_address: 'Tower G-2, Ganga Apt, Pocket 6, Sector D, Vasant Kunj, New Delhi, Delhi 110070',
    home_address: 'Tower G-2, Ganga Apt, New Delhi, Delhi 110070',
    gender: 1,
    site: site,
    zone: Zone.last,
    home_address_latitude: '17.3980155',
    home_address_longitude: '78.5932912'
)

employee4 = Employee.create!(
    employee_id: '3289716',
    employee_company: e_comp,
    home_address: 'Saraswatipuram Jawaharlal Nehru University New Delhi, Delhi 110067',
    gender: 0,
    site: site,
    zone: Zone.last,
    home_address_latitude: '17.3980155',
    home_address_longitude: '78.5932912'
)

employee5 = Employee.create!(
    employee_id: '451456',
    employee_company: e_comp,
    home_address: 'Munirka Village, Bank St, Munirka, New Delhi, Delhi 110067',
    gender: 1,
    site: site,
    zone: Zone.last,
    home_address_latitude: '17.3980155',
    home_address_longitude: '78.5932912'
)

employee6 = Employee.create!(
    employee_id: '7165235',
    employee_company: e_comp,
    home_address: 'Palam Dabari Road, Kali Nagar, Mahavir Enclave I, Mahavir Enclave Part 2, Mahavir Enclave, New Delhi, Delhi 110045',
    gender: 0,
    site: site,
    zone: Zone.last,
    home_address_latitude: '17.3980155',
    home_address_longitude: '78.5932912'
)

employee7 = Employee.create!(
    employee_id: '4523190',
    employee_company: e_comp,
    home_address: '45, Old Som Bazar Rd Block A, Mahavir Enclave Part 1, Mahavir Enclave New Delhi, Delhi 110046',
    gender: 1,
    site: site,
    zone: Zone.last,
    home_address_latitude: '17.3980155',
    home_address_longitude: '78.5932912'
)

employee8 = Employee.create!(
    employee_id: '671452',
    employee_company: e_comp,
    home_address: '236, D Block, Vikaspuri, New Delhi, Delhi 110018',
    gender: 0,
    site: site,
    zone: Zone.last,
    home_address_latitude: '17.3980155',
    home_address_longitude: '78.5932912'
)


User.create! email:'marina.derkach@n3wnormal.com', username: 'marina', password:'password', role: 4, f_name: 'Marina', l_name: 'Derkach', phone: '6666666'
User.create!(
    email:'operator@n3wnormal.com',
    username: 'operator',
    password:'password',
    role: 2,
    f_name: 'Operator',
    l_name: 'Test',
    entity: operator,
    phone: '9998877'
)
User.create! email:'employer@n3wnormal.com', username: 'employer', password:'password', role: 1, f_name: 'Employer', l_name: 'Test', entity:employer, phone: '7776655'

User.create! email:'employee@n3wnormal.com', username: 'employee', password:'password', role: 0, f_name: 'Girish', l_name: 'Kumar', entity:employee, phone: '6665544'
User.create! email:'employee2@n3wnormal.com', username: 'employee2', password:'password', role: 0, f_name: 'Preeti', l_name: 'Mishra', entity: employee2, phone: '66655442'

User.create! email:'driver@n3wnormal.com', username: 'driver', password:'password', role: 3, f_name: 'Driver', l_name: 'Test', entity:driver, phone: '5554433'
User.create! email:'ruslan.yurchenko@n3wnormal.com', username: 'ruslan', password:'password', role: 4, f_name: 'Rus', l_name: 'Rus', phone: '1111111'
User.create! email:'irene.velychko@n3wnormal.com', username: 'irene', password:'password', role: 4, f_name: 'Irene', l_name: 'Batkivna', phone: '4747475'



User.create! email:'mustaq.bijral+dr@inloop.network', username: '665432', password:'password', role: 3, f_name: 'Ghansham', l_name: 'Jeff', entity: driver2, phone: '7838021226'
User.create! email:'nitishmehrotra@gmail.com', username: 'nitish', password:'password', role: 3, f_name: 'Nitish', l_name: 'Mehrotra', entity: driver3, phone: '9663444955'

User.create! email:'mustaq+sm@inloop.network', username: 'mustaq-sm-inloop-network', password:'password', role: 0, f_name: 'Shanku', l_name: 'Mukherjee', entity: employee3, phone: '7838024228'
User.create! email:'mustaq+dk@inloop.network', username: 'mustaq-dk-inloop-network', password:'password', role: 0, f_name: 'Dhruv', l_name: 'Khurana', entity: employee4, phone: '7838024229'
User.create! email:'mustaq+as@inloop.network', username: 'mustaq-as-inloop-network', password:'password', role: 0, f_name: 'Abhinav', l_name: 'Seth', entity: employee5, phone: '7838024227'
User.create! email:'mustaq+ss@inloop.network', username: 'mustaq-ss-inloop-network', password:'password', role: 0, f_name: 'Sumit', l_name: 'Singh', entity: employee6, phone: '7838024226'
User.create! email:'mustaq+sm1@inloop.network', username: 'mustaq-sm1-inloop-network', password:'password', role: 0, f_name: 'Syed', l_name: 'Mudassir', entity: employee7, phone: '7838024225'
User.create! email:'mustaq+tb@inloop.network', username: 'mustaq-tb-inloop-network', password:'password', role: 0, f_name: 'Tulika', l_name: 'Bose', entity: employee8, phone: '6725431477'

User.create! email:'mustaq+rk1@inloop.network', username: '8761528', password:'password', role: 3, f_name: 'Rajesh', l_name: 'Kumar', entity: driver4, phone: '7815432451'
User.create! email:'mustaq+ck1@inloop.nertwork', username: '9876187', password:'password', role: 3, f_name: 'Chandan', l_name: 'Kumar', entity: driver5, phone: '8867451098'
User.create! email:'mustaq+ks@inloop.network', username: '8756789', password:'password', role: 3, f_name: 'Kundan', l_name: 'Sharma', entity: driver6, phone: '8715624314'

# set sequence field to existing notifications
# Notification.all.each do |notification|
#   notification.set_sequence
#   notification.save!
# end

# set sequence to notifications of required trips

trip_time_1 = Time.now - 1.hour
employee_trip_1 = EmployeeTrip.create(site_id: site.id, employee_id: employee.id, trip_type: 0, status: 'trip_created', state: 1, schedule_date: trip_time_1, bus_rider: false, date: trip_time_1, rating: 4)
trip_1 = Trip.create(site_id: site.id, trip_type: 0, status: 'active', employee_trip_ids: [employee_trip_1.id], driver: driver, vehicle: vehicle, start_date: trip_time_1 - 15.minutes)


notifications = Notification.includes(:trip).where('trips.scheduled_date' => Time.now.beginning_of_day.advance(days: -1)..Time.now.end_of_day.advance(days: +1))

notifications.each do |notification|
  notification.set_sequence
  notification.save!
end
