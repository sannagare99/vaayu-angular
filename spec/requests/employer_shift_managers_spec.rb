require 'rails_helper'

RSpec.describe "EmployerShiftManagers", type: :request do
  describe "GET /employer_shift_managers" do
    it "works! (now write some real specs)" do
      get employer_shift_managers_path
      expect(response).to have_http_status(200)
    end
  end
end
