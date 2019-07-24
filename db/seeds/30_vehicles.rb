Vehicle.create!(
    plate_number: 'CA12345AB',
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
    plate_number: 'CA54321AB',
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
