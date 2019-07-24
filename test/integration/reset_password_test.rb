require 'test_helper'

class ResetPasswordTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:operator_user)

    # @TODO: remove later;
    # for some reasons uid was not set when we're creating users from fixtures
    # so, force update fixed it
    @user.save
  end

  test 'reset password sent by email' do
    post '/api/v1/auth/password', params: { email: @user.email }, headers: { 'Accept' => Mime[:json] }

    assert_equal 200, response.status
    assert_equal Mime[:json], response.content_type

    last_email = ActionMailer::Base.deliveries.last
    assert_equal 'Reset password instructions', last_email['subject'].to_s
    assert_equal @user.email, last_email['to'].to_s
    assert_equal true, response.headers.include?('Server-Timestamp')
  end

end
