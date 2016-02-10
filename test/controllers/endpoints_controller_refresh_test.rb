require 'securerandom'
require 'test_helper'

class EndpointsControllerRefreshTest < ActionController::TestCase

  def setup
    @controller = EndpointsController.new
  end

  # negative tests

  test "should fail to refresh non-existent url" do
    sign_in users(:butcher)

    # HTML
    Sidekiq::Testing.inline! do
      post :create, endpoint: { name: "non-existent-html", url: "http://non-existent-#{SecureRandom.hex}.com" }

      assert               refresh_failed_recently? Endpoint.last
    end

    # JSON
    Sidekiq::Testing.inline! do
      post :create, format: :json, endpoint: { name: "non-existent-json", url: "http://non-existent-#{SecureRandom.hex}.com" }

      assert               refresh_failed_recently? Endpoint.last
    end
  end

  # positive tests

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
end