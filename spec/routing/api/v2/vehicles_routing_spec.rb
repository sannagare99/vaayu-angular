require "rails_helper"

RSpec.describe API::V2::VehiclesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/api/v2/vehicles").to route_to("api/v2/vehicles#index")
    end

    it "routes to #new" do
      expect(:get => "/api/v2/vehicles/new").to route_to("api/v2/vehicles#new")
    end

    it "routes to #show" do
      expect(:get => "/api/v2/vehicles/1").to route_to("api/v2/vehicles#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/v2/vehicles/1/edit").to route_to("api/v2/vehicles#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/api/v2/vehicles").to route_to("api/v2/vehicles#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/v2/vehicles/1").to route_to("api/v2/vehicles#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/v2/vehicles/1").to route_to("api/v2/vehicles#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/v2/vehicles/1").to route_to("api/v2/vehicles#destroy", :id => "1")
    end
  end
end
