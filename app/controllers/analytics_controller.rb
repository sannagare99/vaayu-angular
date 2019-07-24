class AnalyticsController < ApplicationController

  def index
  	# @trips = Trip.all.order('id DESC')
   #  attachments["rails.png"] = @trips.to_csv
   #  mail(:to => "Harman Sohanpal harman@pnplabs.in", :subject => "Analytics Data")  	
   #  AnalyticsMailer.analytics_mailer(@trips.to_csv).deliver_now!
  end
end