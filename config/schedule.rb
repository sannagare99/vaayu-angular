env :PATH, ENV['PATH']

every "0 12 1/1 * *" do
  runner "Driver.create_checklist"
end

every "0 12 1/1 * *" do
  runner "Driver.create_notification"
  runner "Vehicle.create_notification"
end