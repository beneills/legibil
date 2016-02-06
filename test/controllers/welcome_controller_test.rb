require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase

  test "should get index when not signed in" do
    get :index
    assert_response :ok
  end

  test "should get index when signed in" do
    sign_in users(:butcher)

    get :index
    assert_response :ok
  end
end
