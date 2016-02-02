require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # negative tests

  test "should not save user without username" do
    user = User.new
    user.password              = "test_password"
    user.password_confirmation = "test_password"
    assert_not user.save, "Saved the user without username"
  end

  test "should not save user without password" do
    user = User.new
    user.username              = "Test User"
    assert_not user.save, "Saved the user without password"
  end

  test "should not save user without password confirmation" do
    user = User.new
    user.username              = "Test User"
    user.password              = "test_password"
    user.password_confirmation = "wrong_pasword"
    assert_not user.save, "Saved the user without password confirmation"
  end

  # positive tests

  test "should save user with longish username" do
    user = User.new
    user.username              = "a" * 30
    user.password              = "test_password"
    user.password_confirmation = "test_password"
    assert user.save, "Couldn't save the user with longish username"
  end

  test "should save user with good data" do
    user = User.new
    user.username              = "Test User"
    user.password              = "test_password"
    user.password_confirmation = "test_password"
    assert user.save, "Couldn't save the user with good data"
  end
end
