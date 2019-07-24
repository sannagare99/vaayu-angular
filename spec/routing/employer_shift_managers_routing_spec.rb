require "rails_helper"

RSpec.describe EmployerShiftManagersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/employer_shift_managers").to route_to("employer_shift_managers#index")
    end

    it "routes to #new" do
      expect(:get => "/employer_shift_managers/new").to route_to("employer_shift_managers#new")
    end

    it "routes to #show" do
      expect(:get => "/employer_shift_managers/1").to route_to("employer_shift_managers#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/employer_shift_managers/1/edit").to route_to("employer_shift_managers#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/employer_shift_managers").to route_to("employer_shift_managers#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/employer_shift_managers/1").to route_to("employer_shift_managers#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/employer_shift_managers/1").to route_to("employer_shift_managers#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/employer_shift_managers/1").to route_to("employer_shift_managers#destroy", :id => "1")
    end

  end
end
