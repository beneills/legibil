require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # negative tests

  test "should not save user without email" do
    user = User.new
    user.password = "password"
    assert_not user.save, "Saved the user with good data"
  end

  test "should not save user without password" do
    user = User.new
    user.email    = "user@example.com"
    assert_not user.save, "Saved the user with good data"
  end

  test "should not save user with short password" do
    user = User.new
    user.email    = "user@example.com"
    user.password = "a" * 7
    assert_not user.save, "Saved the user with good data"
  end

  test "should not save user with bad email" do
    user = User.new
    user.email    = "bad email"
    user.password = "password"
    assert_not user.save, "Saved the user with a bad email"
  end

  # positive tests

  test "should save user with good data" do
    user = User.new
    user.email    = "user@example.com"
    user.password = "password"
    assert user.save, "Couldn't save the user with good data"
  end
end
