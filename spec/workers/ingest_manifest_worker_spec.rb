require 'rails_helper'

RSpec.describe IngestManifestWorker do
  setup do
    create(:site)
    create(:zone)
    create(:shift, start_time: '06:00', end_time: '15:00')
    driver1 = create(:driver)
    driver2 = create(:driver)
    driver3 = create(:driver)
    driver1.user.update!(phone: 7716225412)
    driver2.user.update!(phone: 7716225413)
    driver3.user.update!(phone: 7766998800)
    create(:google_api_key, key: 'AIzaSyB9zg-meOLbs_zaVcVt1myvUU8se4Cb0UE')
    allow(UserNotifierMailer).to receive_message_chain(:user_create, :deliver_now!)
  end

  let(:ingest_manifest_job) { create(:ingest_manifest_job) }

  setup do
    allow_any_instance_of(IngestManifestWorker).to receive(:file_url).and_return(Rails.root.join('spec', 'fixtures', 'files', 'ingest_manifest.xlsx').to_s)
  end

  it 'should create 3 employee clusters' do
    expect {
      subject.perform(ingest_manifest_job.id)
    }.to change {
      EmployeeCluster.count
    }.by(3)
  end

  it 'should create 6 employee trips' do
    expect {
      subject.perform(ingest_manifest_job.id)
    }.to change {
      EmployeeTrip.count
    }.by(6)
    expect(EmployeeTrip.pluck(:status).uniq).to eq(['upcoming'])
  end

  it 'should provision 6 employees' do
    expect {
      subject.perform(ingest_manifest_job.id)
    }.to change {
      Employee.count
    }.by(6)
  end

  it 'should be idempotent' do
    ingest_manifest_job2 = create(:ingest_manifest_job)
    expect {
      subject.perform(ingest_manifest_job.id)
      subject.perform(ingest_manifest_job2.id)
    }.to change {
      EmployeeCluster.count
    }.by(3)
  end

  it 'should mark ingest_manifest_job as completed' do
    subject.perform(ingest_manifest_job.id)
    ingest_manifest_job.reload
    expect(ingest_manifest_job.status).to eq('completed')
  end

  it 'should have the right stats' do
    subject.perform(ingest_manifest_job.id)
    ingest_manifest_job.reload
    expect(ingest_manifest_job.processed_row_count).to eq(6)
    expect(ingest_manifest_job.failed_row_count).to eq(0)
    expect(ingest_manifest_job.schedule_updated_count).to eq(0)
    expect(ingest_manifest_job.employee_provisioned_count).to eq(6)
    expect(ingest_manifest_job.schedule_provisioned_count).to eq(0)
    expect(ingest_manifest_job.schedule_assigned_count).to eq(6)
  end
end
