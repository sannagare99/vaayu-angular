require 'rails_helper'

RSpec.describe IngestEmployeeShiftWorker do
  setup do
    create(:site)
    create(:zone)
    allow(UserNotifierMailer).to receive_message_chain(:user_create, :deliver_now!)
    allow_any_instance_of(IngestEmployeeShiftWorker).to receive(:file_url).and_return(Rails.root.join('spec', 'fixtures', 'files', 'Ingest Excel Format.xlsx').to_s)
  end

  let(:ingest_job) { create(:ingest_job) }

  context 'ingest success' do
    setup do
      create(:shift, start_time: '9:00', end_time: '18:00')
      create(:shift, start_time: '9:30', end_time: '18:30')
      create(:shift, start_time: '10:00', end_time: '19:00')
    end

    context 'new employee' do
      it 'should create employee' do
        expect {
          subject.perform(ingest_job.id)
        }.to change {
          Employee.count
        }.by(1)
      end

      it 'should create 6 employee trips' do
        expect {
          subject.perform(ingest_job.id)
        }.to change {
          EmployeeTrip.count
        }.by(6)
      end

      it 'should not create an error file' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.error_file.exists?).to eq(false)
      end

      it 'should mark ingest job as completed' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.status).to eq('completed')
      end

      it 'should have correct stats' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.processed_row_count).to eq(1)
        expect(ingest_job.failed_row_count).to eq(0)
        expect(ingest_job.schedule_updated_count).to eq(0)
        expect(ingest_job.schedule_assigned_count).to eq(3)
        expect(ingest_job.employee_provisioned_count).to eq(1)
        expect(ingest_job.schedule_provisioned_count).to eq(0)
      end

      it 'should be idempotent' do
        ingest_job2 = create(:ingest_job)
        expect {
          subject.perform(ingest_job.id)
          subject.perform(ingest_job2.id)
        }.to change {
          EmployeeTrip.count
        }.by(6)
      end
    end

    context 'existing employee' do
      let!(:employee) {
        e = create(:employee)
        e.user.update!(email: 'dhruva@tarkalabs.com')
        e
      }

      setup do
        Shift.all.each do |shift|
          employee.user.shift_users.create!(shift: shift)
        end
      end

      it 'should not create employee' do
        expect {
          subject.perform(ingest_job.id)
        }.to_not change {
          Employee.count
        }
      end

      it 'should create 6 employee trips' do
        expect {
          subject.perform(ingest_job.id)
        }.to change {
          EmployeeTrip.count
        }.by(6)
      end

      it 'should not create an error file' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.error_file.exists?).to eq(false)
      end

      it 'should mark ingest job as completed' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.status).to eq('completed')
      end

      it 'should have correct stats' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.processed_row_count).to eq(1)
        expect(ingest_job.failed_row_count).to eq(0)
        expect(ingest_job.schedule_updated_count).to eq(0)
        expect(ingest_job.schedule_assigned_count).to eq(0)
        expect(ingest_job.employee_provisioned_count).to eq(0)
        expect(ingest_job.schedule_provisioned_count).to eq(0)
      end

      it 'should be idempotent' do
        ingest_job2 = create(:ingest_job)
        expect {
          subject.perform(ingest_job.id)
          subject.perform(ingest_job2.id)
        }.to change {
          EmployeeTrip.count
        }.by(6)
      end
    end
  end

  context 'ingest error' do
    context 'existing shift' do
      setup do
        create(:shift, start_time: '9:00', end_time: '18:00')
        create(:shift, start_time: '9:30', end_time: '18:30')
        create(:shift, start_time: '10:00', end_time: '19:00')
        allow_any_instance_of(IngestEmployeeShiftWorker).to receive(:file_url).and_return(Rails.root.join('spec', 'fixtures', 'files', 'Ingest Excel Format Error.xlsx').to_s)
      end

      it 'should not create employee' do
        expect {
          subject.perform(ingest_job.id)
        }.to_not change {
          Employee.count
        }
      end

      it 'should create an error file' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.error_file.exists?).to eq(true)
        expect(Paperclip.io_adapters.for(ingest_job.error_file).read).to eq("ingest_job_id,employee_id,row_index,error\n#{ingest_job.id},EMP001,1,Validation failed: Gender can't be blank\n")
      end

      it 'should mark ingest job as failed' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.status).to eq('failed')
      end

      it 'should have correct stats' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.processed_row_count).to eq(1)
        expect(ingest_job.failed_row_count).to eq(1)
        expect(ingest_job.schedule_updated_count).to eq(0)
        expect(ingest_job.schedule_assigned_count).to eq(0)
        expect(ingest_job.employee_provisioned_count).to eq(0)
        expect(ingest_job.schedule_provisioned_count).to eq(0)
      end
    end

    context 'missing shift' do
      let(:ingest_job) { create(:ingest_job) }

      it 'should create employee' do
        expect {
          subject.perform(ingest_job.id)
        }.to change {
          Employee.count
        }.by(1)
      end

      it 'should create 6 employee trips' do
        expect {
          subject.perform(ingest_job.id)
        }.to change {
          EmployeeTrip.count
        }.by(6)
      end

      it 'should create 3 shifts' do
        expect {
          subject.perform(ingest_job.id)
        }.to change {
          Shift.count
        }.by(3)
        expect(Shift.pluck(:name)).to eq(['9:00 - 18:00', '9:30 - 18:30', '10:00 - 19:00'])
      end

      it 'should not create an error file' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.error_file.exists?).to eq(false)
      end

      it 'should mark ingest job as completed' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.status).to eq('completed')
      end

      it 'should have correct stats' do
        subject.perform(ingest_job.id)
        ingest_job.reload
        expect(ingest_job.processed_row_count).to eq(1)
        expect(ingest_job.failed_row_count).to eq(0)
        expect(ingest_job.schedule_updated_count).to eq(0)
        expect(ingest_job.schedule_assigned_count).to eq(0)
        expect(ingest_job.employee_provisioned_count).to eq(1)
        expect(ingest_job.schedule_provisioned_count).to eq(3)
      end

      it 'should be idempotent' do
        ingest_job2 = create(:ingest_job)
        expect {
          subject.perform(ingest_job.id)
          subject.perform(ingest_job2.id)
        }.to change {
          EmployeeTrip.count
        }.by(6)
      end
    end
  end
end
