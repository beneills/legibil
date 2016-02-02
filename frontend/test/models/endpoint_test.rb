require 'test_helper'

class EndpointTest < ActiveSupport::TestCase

  # negative tests

  test "should not save endpoint without url" do
    endpoint = Endpoint.new
    endpoint.name = "Test Endpoint"
    endpoint.user = users(:one)
    assert_not endpoint.save, "Saved the endpoint without url"
  end

  test "should not save endpoint without name" do
    endpoint = Endpoint.new
    endpoint.url = "http://example.com/resource"
    endpoint.user = users(:one)
    assert_not endpoint.save, "Saved the endpoint without name"
  end

  test "should not save endpoint without user" do
    endpoint = Endpoint.new
    endpoint.url = "http://example.com/resource"
    endpoint.name = "Test Endpoint"
    assert_not endpoint.save, "Saved the endpoint without user"
  end

  test "should not save endpoint with long name" do
    endpoint = Endpoint.new
    endpoint.url = "http://example.com/resource"
    endpoint.name = "a" * 31
    endpoint.user = users(:one)
    assert_not endpoint.save, "Saved the endpoint with a long name"
  end

  # positive tests

  test "should save endpoint with longish name" do
    endpoint = Endpoint.new
    endpoint.url = "http://example.com/resource"
    endpoint.name = "a" * 30
    endpoint.user = users(:one)
    assert endpoint.save, "Couldn't save the endpoint with a longish name"
  end

  test "should save endpoint with good data" do
    endpoint = Endpoint.new
    endpoint.url = "http://example.com/resource"
    endpoint.name = "Test Endpoint"
    endpoint.user = users(:one)
    assert endpoint.save, "Couldn't save the endpoint with good data"
  end
end
