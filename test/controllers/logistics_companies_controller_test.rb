require 'test_helper'

class LogisticsCompaniesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get logistics_companies_new_url
    assert_response :success
  end

  test "should get edit" do
    get logistics_companies_edit_url
    assert_response :success
  end

  test "should get index" do
    get logistics_companies_index_url
    assert_response :success
  end

end
