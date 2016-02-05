require 'test_helper'

class EndpointsControllerTest < ActionController::TestCase
  setup do
    @endpoint = endpoints(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:endpoints)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create endpoint" do
    assert_difference('Endpoint.count') do
      post :create, endpoint: { name: @endpoint.name, url: @endpoint.url, user: @endpoint.user }
    end

    assert_redirected_to endpoint_path(assigns(:endpoint))
  end

  test "should show endpoint" do
    get :show, id: @endpoint
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @endpoint
    assert_response :success
  end

  test "should update endpoint" do
    patch :update, id: @endpoint, endpoint: { name: @endpoint.name, url: @endpoint.url, user: @endpoint.user }
    assert_redirected_to endpoint_path(assigns(:endpoint))
  end

  test "should destroy endpoint" do
    assert_difference('Endpoint.count', -1) do
      delete :destroy, id: @endpoint
    end

    assert_redirected_to endpoints_path
  end
end
