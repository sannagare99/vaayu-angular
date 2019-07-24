describe EmployeeSchedule, type: :model do

  it { should have_many(:employee_trips) }
  it { should belong_to(:employee) }
  # it { should validate_presence_of(:day) }
  # it { should validate_uniqueness_of(:day).scoped_to(:employee_id)}

end