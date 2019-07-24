require 'rails_helper'

RSpec.describe AutoCreateEmployeeTripsWorker do
  context 'without EmployeeCluster' do
    setup do
      create(:employee_trip, schedule_date: Time.now)
    end

    it 'should create same EmployeeTrip for next week' do
      expect {
        subject.perform
      }.to change {
        EmployeeTrip.count
      }.by(1)
      expect(EmployeeTrip.last.date.to_date).to eq((Time.now.utc + 7.days).to_date)
    end
  end

  context 'with EmployeeCluster' do
    setup do
      employee_cluster = create(:employee_cluster)
      create(:employee_trip, {
        date: Time.now,
        schedule_date: Time.now,
        employee_cluster: employee_cluster
      })
      create(:employee_trip, {
        date: Time.now,
        schedule_date: Time.now,
        employee_cluster: employee_cluster
      })
    end

    it 'should recreate EmployeeCluster for next week' do
      expect {
        subject.perform
      }.to change {
        EmployeeCluster.count
      }.by(1)
      expect(EmployeeCluster.last.employee_trips.count).to eq(2)
    end

    it 'should create same EmployeeTrip for next week' do
      expect {
        subject.perform
      }.to change {
        EmployeeTrip.count
      }.by(2)
      expect(EmployeeTrip.last(2).pluck(:date).map(&:to_date)).to(
        contain_exactly(*[(Time.now.utc + 7.days).to_date]*2)
      )
    end
  end

  context 'with and without EmployeeCluster' do
    setup do
      create(:employee_trip, schedule_date: Time.now)
      create(:employee_trip, schedule_date: Time.now)
      employee_cluster = create(:employee_cluster)
      create(:employee_trip, {
        schedule_date: Time.now,
        employee_cluster: employee_cluster
      })
      create(:employee_trip, {
        schedule_date: Time.now,
        employee_cluster: employee_cluster
      })
    end

    it 'should recreate EmployeeCluster for next week' do
      expect {
        subject.perform
      }.to change {
        EmployeeCluster.count
      }.by(1)
      expect(EmployeeCluster.last.employee_trips.count).to eq(2)
    end

    it 'should create same EmployeeTrip for next week' do
      expect {
        subject.perform
      }.to change {
        EmployeeTrip.count
      }.by(4)
      expect(EmployeeTrip.last(4).pluck(:date).map(&:to_date)).to(
        contain_exactly(*[(Time.now.utc + 7.days).to_date]*4)
      )
    end
  end
end
