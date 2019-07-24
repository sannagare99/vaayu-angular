require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

And(/^I fill "([^"]*)" field with operator's email$/) do |arg|
  page.find(arg).set(@operator.email)
  sleep(1)
end