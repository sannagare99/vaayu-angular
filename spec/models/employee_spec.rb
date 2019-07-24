describe Employee, type: :model do
  before do
    allow_any_instance_of(GoogleMapsService::Client)
        .to receive_message_chain(:geocode, :first)
                .and_return({geometry: { location: {lat: 100, lng: 200} }})

    allow_any_instance_of(GoogleMapsService::Client)
        .to receive(:distance_matrix)
                .and_return({status: 'OK', rows: [elements: [distance: {value: 123456}, status: 'OK']]})
  end

  let(:address_generator) { RandomData::Address.new }
  let(:address) { address_generator.generate }
  let(:site) { FactoryGirl.create(:site, address: address_generator.generate) }
  let!(:employee) { FactoryGirl.build(:employee, home_address: address, site: site) }

  subject { employee }


  context '#set_home_address_coordinates'
  context '#calculate_distance_to_site'
  context '#home_address_location_calculated'
  context '#distance_to_site_calculated'

  context 'validations' do
    it { should have_one(:user).dependent(:destroy) }
    it { should belong_to(:site) }
    it { should belong_to(:zone) }
    it { should belong_to(:employee_company) }
    it { should have_many(:employee_schedules).dependent(:destroy) }
    it { should have_many(:employee_trips).dependent(:destroy) }
    it { should have_many(:trip_change_requests).dependent(:destroy) }


    it { should validate_presence_of(:gender) }
    it { expect(employee.home_address).not_to be_blank }
    it { should validate_presence_of(:site) }
    it { should validate_presence_of(:zone) }
    it { should validate_presence_of(:employee_company) }

    context 'before validate' do
      context 'set_home_address_coordinates' do
        it 'coordinates should be nil' do
          allow_any_instance_of(GoogleMapsService::Client).to receive_message_chain(:geocode, :first).and_return({})
          employee = FactoryGirl.build(:employee, home_address: address, site: site)

          employee.valid?
          expect(employee.home_address_latitude).to be_nil
          expect(employee.home_address_longitude).to be_nil
        end

        it 'should return errors when home address blank' do
          expect(employee.home_address).not_to be_blank
        end

        it 'should set home address coordinates when validate' do
          employee = FactoryGirl.build(:employee, home_address: address, site: site)

          employee.valid?
          expect(employee.home_address_latitude).not_to be_blank
          expect(employee.home_address_longitude).not_to be_blank
        end

        it 'coordinates should be nil' do
          allow_any_instance_of(GoogleMapsService::Client).to receive_message_chain(:geocode, :first).and_return({})
          employee = FactoryGirl.build(:employee, home_address: address, site: site)

          employee.valid?
          expect(employee.home_address_latitude).to be_nil
          expect(employee.home_address_longitude).to be_nil
        end

        it 'should return errors when home address blank' do
          expect(employee.home_address).not_to be_blank
        end

        it 'should set home address coordinates when validate' do
          employee = FactoryGirl.build(:employee, home_address: address, site: site)

          employee.valid?
          expect(employee.home_address_latitude).not_to be_blank
          expect(employee.home_address_longitude).not_to be_blank
        end
      end

      context '#calculate_distance_to_site' do
        before do
          allow(employee).to receive(:set_home_address_coordinates)
          allow(employee).to receive(:home_address_location).and_return([10, 20])
        end

        it 'should return right distance' do
          employee.valid?
          expect(employee.distance_to_site).to eql(123456)
        end

        it 'should return error when distance is blank' do
          allow_any_instance_of(GoogleMapsService::Client)
              .to receive(:distance_matrix)
                      .and_return({})

          employee.valid?
          expect(employee.distance_to_site).to be_nil
        end
      end
    end
  end

  context 'guard scopes' do
    let!(:q) {Employee.where(is_guard: false).count}
    before do
      3.times { FactoryGirl.create(:employee, is_guard: false) }
      2.times { FactoryGirl.create(:employee, is_guard: true) }
    end

    it "should return employees/not guard" do
      expect(Employee.not_guard.count).to eq (q+3)
    end

    it "should return guard" do
      expect(Employee.guard.count).to eq 2
    end
  end

  context '#home_address_location_calculated' do
    before do
      allow(employee).to receive(:set_home_address_coordinates)
      allow(employee).to receive(:calculate_distance_to_site)
      allow(employee).to receive(:distance_to_site).and_return(10345)
    end

    it 'should return right distance' do
      employee.valid?
      expect(employee.distance_to_site).to eql(10345)
    end

    it 'should not have error when home_address present' do
      allow(employee).to receive(:home_address_latitude).and_return(10)
      allow(employee).to receive(:home_address_longitude).and_return(12)
      employee.valid?

      expect(employee.errors.full_messages).to be_empty
    end

    it 'should have error when home_address is not present' do
      employee.valid?

      expect(employee.errors.full_messages).to include('Home address not found on Google Maps. Please use valid home address.')
    end
  end

  context '#distance_to_site_calculated' do
    before do
      allow(employee).to receive(:set_home_address_coordinates)
      allow(employee).to receive(:calculate_distance_to_site)
      allow(employee).to receive(:home_address_latitude).and_return(10)
      allow(employee).to receive(:home_address_longitude).and_return(12)
    end

    it 'should not have error when distance_to_site present' do
      allow(employee).to receive(:distance_to_site).and_return(10345)
      employee.valid?

      expect(employee.errors.full_messages).to be_empty
    end

    it 'should have error when distance_to_site is not present' do
      employee.valid?

      expect(employee.errors.full_messages).to include('Home address unable to calculate distance from home to site, please use valid address')
    end
  end
end
