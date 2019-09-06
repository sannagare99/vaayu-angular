require "rails_helper"

RSpec.describe API::V2::BusinessAssociatesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/api/v2/business_associates").to route_to("api/v2/business_associates#index")
    end

    it "routes to #new" do
      expect(:get => "/api/v2/business_associates/new").to route_to("api/v2/business_associates#new")
    end

    it "routes to #show" do
      expect(:get => "/api/v2/business_associates/1").to route_to("api/v2/business_associates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api/v2/business_associates/1/edit").to route_to("api/v2/business_associates#edit", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/api/v2/business_associates").to route_to("api/v2/business_associates#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api/v2/business_associates/1").to route_to("api/v2/business_associates#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api/v2/business_associates/1").to route_to("api/v2/business_associates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api/v2/business_associates/1").to route_to("api/v2/business_associates#destroy", :id => "1")
    end
  end
end
