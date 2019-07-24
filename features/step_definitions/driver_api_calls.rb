require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given(/^Driver check in request$/) do
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  HTTParty.post(host + "/api/v1/drivers/#{@driver.user.id}/on_duty",
                                     {
                                         :body => {"plate_number": @driver.vehicle.plate_number},
                                         :headers => @auth_token_driver
                                     })
end

Given(/^Driver accept income trip request$/) do
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  HTTParty.get(host + '/api/v1/trips/1/accept_trip_request',
                                     {
                                         :headers => @auth_token_driver
                                     })

end

Given(/^Driver decline income trip request$/) do
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  HTTParty.get(host + '/api/v1/trips/1/decline_trip_request',
                                       {
                                           :headers => @auth_token_driver
                                       })
end

Given(/^Start trip by driver request$/) do
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  HTTParty.get(host + '/api/v1/trips/1/start',
                                       {
                                           :headers => @auth_token_driver,
                                           :query => {
                                               :lat => 17.3980155,
                                               :lng => 78.5932912
                                           }
                                       })
end

Given(/^Driver arrived request$/) do
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  HTTParty.post(host + '/api/v1/trips/1/trip_routes/driver_arrived',
                                       {
                                           :headers => @auth_token_driver,
                                           :body => {  'trip_routes': [ '1' ]}
                                       })
end

Given(/^Driver: create employee no show trip exception request$/) do
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  HTTParty.get(host + '/api/v1/trip_routes/1/employee_no_show',
                            {
                                :headers => @auth_token_driver
                            })
end

Given(/^Driver: create employee no show trip exception request for trip id (\d*)$/) do |trip_id|
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  HTTParty.get(host + "/api/v1/trip_routes/#{trip_id}/employee_no_show",
                            {
                                :headers => @auth_token_driver
                            })
end

Given(/^Driver onboards passanger request$/) do
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  HTTParty.post(host + '/api/v1/trips/1/trip_routes/on_board',
                           {
                               :headers => @auth_token_driver,
                               :body => {  'trip_routes': [ '1' ]}
                           })
end

Given(/^Driver completed a trip route request$/) do
  host = "http://" + Capybara.current_session.server.host + ":" + Capybara.current_session.server.port.to_s

  HTTParty.post(host + '/api/v1/trips/1/trip_routes/completed',
                           {
                               :headers => @auth_token_driver,
                               :body => {  'trip_routes': [ '1' ]}
                           })

  # binding.pry
end