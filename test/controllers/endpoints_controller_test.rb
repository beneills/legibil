require 'test_helper'

class EndpointsControllerTest < ActionController::TestCase
  setup do
    @cook = endpoints(:cook)
    @bake = endpoints(:bake)
  end

  # negative tests

  test "should not create endpoint when not signed in" do
    assert_no_difference('Endpoint.count') do
      post :create, endpoint: endpoint_data
    end

    assert_response 403
  end

  test "should not create endpoints with duplicate urls" do
    sign_in users(:butcher)

    # make first endpoint
    assert_difference('Endpoint.count') do
      post :create, endpoint: { name: 'chop', url: 'example.con/butchers/cut' }
    end

    assert_response 302

    # make second endpoint
    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: 'slice', url: 'example.con/butchers/cut' }
    end

    # expect conflict
    assert_response 409
  end

  test "should not create endpoints with duplicate names" do
    sign_in users(:butcher)

    # make first endpoint
    assert_difference('Endpoint.count') do
      post :create, endpoint: { name: 'order', url: 'example.com/butchers/buy' }
    end

    assert_response 302

    # make second endpoint
    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: 'order', url: 'example.com/butchers/purchase' }
    end

    assert_response 409
  end

  test "should not create endpoint with short name" do
    sign_in users(:butcher)

    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: '', url: 'example.com/endpoint' }
    end

    assert_response 409
  end

  test "should not update endpoint owned by another user" do
    sign_in users(:butcher)

    patch :update, id: users(:chef).endpoints.first, endpoint: endpoint_data

    assert_response 403
  end

  test "should not destroy endpoint owned by another user" do
    sign_in users(:butcher)

    assert_no_difference('Endpoint.count') do
      delete :destroy, id: users(:chef).endpoints.first
    end

    assert_response 403
  end

  # positive tests

  test "should create endpoint" do
    sign_in users(:butcher)

    assert_difference('Endpoint.count') do
      post :create, endpoint: endpoint_data
    end

    assert_equal(endpoint_data[:name], Endpoint.last.name)
    assert_equal(endpoint_data[:url],  Endpoint.last.url)
    assert_equal(users(:butcher).id,   Endpoint.last.user.id)

    assert_redirected_to root_url
  end

  test "should update endpoint" do
    sign_in users(:butcher)

    post :create, endpoint: endpoint_data

    patch :update, id: users(:butcher).endpoints.first, endpoint: endpoint_data

    assert_redirected_to root_url
  end

  test "should destroy endpoint" do
    sign_in users(:butcher)

    post :create, endpoint: endpoint_data

    assert_difference('Endpoint.count', -1) do
      delete :destroy, id: users(:butcher).endpoints.first
    end

    assert_redirected_to root_url
  end

  private
    def endpoint_data
      { name: 'my endpoint', url: 'example.com/endpoint' }
    end
end
