require File.expand_path(File.join(File.dirname(__FILE__), "../../", "support", "paths"))

When(/^I am try to log in as employer$/) do
  page.find("#user_username").set(@user_employer.email)
  sleep(1)
  page.find("#user_password").set('n3wnormal')
  sleep(1)
  page.find('.btn-primary').click
end

And(/^I fill "([^"]*)" field with incorrect employer's email$/) do |arg|
  page.find(arg).set('123'+@user_employer.email)
  sleep(1)
end

When(/^I am try to log in as employer with incorrect "([^"]*)"$/) do |field|
  email = (field!="Email")? @user_employer.email : ('123' + @user_employer.email)
  password = (field!="Password")? 'n3wnormal' : '123n3wnormal'
  page.find("#user_username").set(email)
  sleep(1)
  page.find("#user_password").set(password)
  sleep(1)
  page.find('.btn-primary').click
end