require 'test_helper'

class ProvisioningControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get provisioning_index_url
    assert_response :success
  end

end
