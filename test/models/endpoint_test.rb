require 'test_helper'

class EndpointTest < ActiveSupport::TestCase

  # negative tests

  test "should not save endpoint without url" do
    endpoint = Endpoint.new
    endpoint.name = "serve"
    endpoint.user = users(:chef)
    assert_not endpoint.save, "Saved the endpoint without url"
  end

  test "should not save endpoint without name" do
    endpoint = Endpoint.new
    endpoint.url  = "example.com/restaurant/serve"
    endpoint.user = users(:chef)
    assert_not endpoint.save, "Saved the endpoint without name"
  end

  test "should not save endpoint without user" do
    endpoint = Endpoint.new
    endpoint.url  = "example.com/restaurant/serve"
    endpoint.name = "serve"
    assert_not endpoint.save, "Saved the endpoint without user"
  end

  test "should not save endpoint with long name" do
    endpoint = Endpoint.new
    endpoint.url  = "example.com/restaurant/serve"
    endpoint.name = "a" * 31
    endpoint.user = users(:chef)
    assert_not endpoint.save, "Saved the endpoint with a long name"
  end

  test "should not save endpoint with bad url" do
    endpoint = Endpoint.new
    endpoint.url  = "bad url"
    endpoint.name = "serve"
    endpoint.user = users(:chef)
    assert_not endpoint.save, "Saved the endpoint with a bad url"
  end

  # positive tests

  test "should save endpoint with longish name" do
    endpoint = Endpoint.new
    endpoint.url = "example.com/restaurant/serve"
    endpoint.name = "a" * 30
    endpoint.user = users(:chef)
    assert endpoint.save, "Couldn't save the endpoint with a longish name"
  end

  test "should save endpoint with good data" do
    endpoint = Endpoint.new
    endpoint.url = "example.com/restaurant/serve"
    endpoint.name = "serve"
    endpoint.user = users(:chef)
    assert endpoint.save, "Couldn't save the endpoint with good data"
  end
end
