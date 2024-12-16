require "test_helper"

class CronofyAuthControllerTest < ActionDispatch::IntegrationTest
  test "should get connect" do
    get cronofy_auth_connect_url
    assert_response :success
  end

  test "should get callback" do
    get cronofy_auth_callback_url
    assert_response :success
  end
end
