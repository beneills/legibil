require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # positive tests

  test "should save user with good data" do
    user = User.new
    assert user.save, "Couldn't save the user with good data"
  end
end
