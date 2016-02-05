require 'test_helper'

class EndpointsControllerTest < ActionController::TestCase
  setup do
    @endpoint = endpoints(:one)
  end

  # negative tests

  test "should not create endpoint when not signed in" do
    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: @endpoint.name, url: @endpoint.url }
    end

    assert_response 403
  end

  test "should not create endpoints with duplicate urls" do
    sign_in users(:one)

    # make first endpoint
    assert_difference('Endpoint.count') do
      post :create, endpoint: { name: 'name1', url: 'url1' }
    end

    assert_response 302

    # make second endpoint
    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: 'name2', url: 'url1' }
    end

    # expect conflict
    assert_response 409
  end

  test "should not create endpoints with duplicate names" do
    sign_in users(:one)

    # make first endpoint
    assert_difference('Endpoint.count') do
      post :create, endpoint: { name: 'name3', url: 'url2' }
    end

    assert_response 302

    # make second endpoint
    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: 'name3', url: 'url3' }
    end

    assert_response 409
  end

  test "should not create endpoint with short name" do
    sign_in users(:one)

    assert_no_difference('Endpoint.count') do
      post :create, endpoint: { name: '', url: 'url4' }
    end

    assert_response 409
  end

  test "should not update endpoint owned by another user" do
    sign_in users(:one)

    patch :update, id: users(:two).endpoints.first, endpoint: { name: 'n', url: 'u' }

    assert_response 403
  end

  # positive tests

  test "should create endpoint" do
    sign_in users(:two)

    assert_difference('Endpoint.count') do
      post :create, endpoint: { name: @endpoint.name, url: @endpoint.url }
    end

    assert_equal(@endpoint.name, Endpoint.last.name)
    assert_equal(@endpoint.url,  Endpoint.last.url)
    assert_equal(users(:two).id, Endpoint.last.user.id)

    assert_redirected_to root_url
  end

  test "should update endpoint" do
    sign_in users(:one)

    patch :update, id: @endpoint, endpoint: { name: @endpoint.name, url: @endpoint.url }

    assert_redirected_to root_url
  end

  # test "should destroy endpoint" do
  #   assert_difference('Endpoint.count', -1) do
  #     delete :destroy, id: @endpoint
  #   end

  #   assert_redirected_to endpoints_path
  # end
end
