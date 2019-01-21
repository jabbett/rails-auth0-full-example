require 'test_helper'

class SecureControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get secure_show_url
    assert_response :success
  end

end
