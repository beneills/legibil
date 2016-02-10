require 'sidekiq/testing'
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

    assert_response :forbidden
  end

  test "should not create endpoints with duplicate urls" do
    sign_in users(:butcher)

    # make first endpoint
    assert_difference('Endpoint.count') do
      post :create, endpoint: { name: 'chop', url: 'example.con/butchers/cut' }
    end

    # make second endpoint
    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: 'slice', url: 'example.con/butchers/cut' }
    end

    assert_response :unprocessable_entity
  end

  test "should not create endpoints with duplicate names" do
    sign_in users(:butcher)

    # make first endpoint
    assert_difference('Endpoint.count') do
      post :create, endpoint: { name: 'order', url: 'example.com/butchers/buy' }
    end

    # make second endpoint
    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: 'order', url: 'example.com/butchers/purchase' }
    end

    assert_response :unprocessable_entity
  end

  test "should not create endpoint with short name" do
    sign_in users(:butcher)

    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: '', url: 'example.com/endpoint' }
    end

    assert_response :unprocessable_entity
  end

  test "should not update endpoint owned by another user" do
    sign_in users(:butcher)

    patch :update, id: users(:chef).endpoints.first, endpoint: endpoint_data

    assert_response :forbidden
  end

  test "should not destroy endpoint owned by another user" do
    sign_in users(:butcher)

    assert_no_difference('Endpoint.count') do
      delete :destroy, id: users(:chef).endpoints.first
    end

    assert_response :forbidden
  end

  # positive tests

  test "should create endpoint" do
    sign_in users(:butcher)

    # HTML
    assert_difference('Endpoint.count') do
      post :create, endpoint: endpoint_data('create_html')
    end

    assert_equal(endpoint_data('create_html')[:name], Endpoint.last.name)
    assert_equal(endpoint_data('create_html')[:url],  Endpoint.last.url)
    assert_equal(users(:butcher).id,                  Endpoint.last.user.id)
    assert_redirected_to root_url

    # JSON
    post :create, format: :json, endpoint: endpoint_data('create_json')

    assert_response :created
    assert_empty    @response.body
  end

  test "should update endpoint" do
    sign_in users(:butcher)

    # HTML
    post :create, endpoint: endpoint_data('update_html')
    patch :update, id: users(:butcher).endpoints.first, endpoint: endpoint_data('update')

    assert_redirected_to root_url

    # JSON
    post :create, format: :json, endpoint: endpoint_data('update_json')
    patch :update, format: :json, id: users(:butcher).endpoints.first, endpoint: endpoint_data('update_json')

    assert_response :ok
    assert_empty    @response.body
  end

  test "should destroy endpoint" do
    sign_in users(:butcher)

    # HTML
    post :create, endpoint: endpoint_data('delete_html')

    assert_difference('Endpoint.count', -1) do
      delete :destroy, id: users(:butcher).endpoints.last
    end

    assert_redirected_to root_url

    # JSON
    post :create, format: :json, endpoint: endpoint_data('delete_json')
    delete :destroy, format: :json, id: users(:butcher).endpoints.last

    assert_response :no_content
    assert_empty    @response.body
  end

  test "should trigger auto-refresh upon job creation" do
    sign_in users(:butcher)

    # HTML
    post :create, endpoint: endpoint_data('refresh_html')

    assert refresh_requested_recently? Endpoint.last

    # JSON
    post :create, format: :json, endpoint: endpoint_data('refresh_json')

    assert refresh_requested_recently? Endpoint.last
  end

  test "should trigger refresh when asked" do
    sign_in users(:butcher)

    # HTML
    Sidekiq::Testing.inline! do
      post :create, endpoint: endpoint_data('refresh_html')
    end

    patch :refresh, id: users(:butcher).endpoints.last

    assert_redirected_to root_url
    assert               refresh_requested_recently? Endpoint.last

    # JSON
    Sidekiq::Testing.inline! do
      post :create, format: :json, endpoint: endpoint_data('refresh_json')
    end

    patch :refresh, format: :json, id: users(:butcher).endpoints.last

    assert_response :ok
    assert_empty    @response.body
    assert          refresh_requested_recently? Endpoint.last
  end

  test "should complete refresh job" do
    sign_in users(:butcher)

    # HTML
    Sidekiq::Testing.inline! do
      post :create, endpoint: endpoint_data('refresh_html')

      patch :refresh, id: users(:butcher).endpoints.last

      assert               refreshed_recently? Endpoint.last
    end

    # JSON
    Sidekiq::Testing.inline! do
      post :create, format: :json, endpoint: endpoint_data('refresh_json')

      patch :refresh, format: :json, id: users(:butcher).endpoints.last

      assert          refreshed_recently? Endpoint.last
    end
  end

  private
    def endpoint_data(identifier = '')
      { name: "my endpoint#{identifier}", url: "http://example.com/endpoint#{identifier}" }
    end
end
