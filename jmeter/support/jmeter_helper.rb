require 'ruby-jmeter'
require File.expand_path("../../../config/environment.rb", __FILE__)

def host_url
	ARGV[0]
end

def threads_count
	ARGV[1]
end

def rampup_time
	ARGV[2]
end

def loop_count
	ARGV[3]
end

def get_driver
	Driver.includes(:user, :trips).first
end

def get_operator
	Operator.includes(:user).first
end

def get_employer
	Employer.includes(:user).first
end

def get_site_with_trips
	Site.joins(:trips).first
end

def get_employee_with_employee_trips
	Employee.includes(:user).joins(:employee_trips).first
end

def get_trip_with_assigned_driver
	Trip.joins(driver: :user).first
end

