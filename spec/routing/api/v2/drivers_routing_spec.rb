require "rails_helper"

RSpec.describe API::V2::DriversController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/api/v2/drivers").to route_to("api/v2/drivers#index")
    end

    it "routes to #new" do
      expect(:get => "/api/v2/drivers/new").to route_to("api/v2/drivers#new")
    end

    it "routes to #show" do
      expect(:get => "/api/v2/drivers/1").to route_to("api/v2/drivers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/v2/drivers/1/edit").to route_to("api/v2/drivers#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/api/v2/drivers").to route_to("api/v2/drivers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/v2/drivers/1").to route_to("api/v2/drivers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/v2/drivers/1").to route_to("api/v2/drivers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/v2/drivers/1").to route_to("api/v2/drivers#destroy", :id => "1")
    end
  end
end
