ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def refreshed_recently?(endpoint)
    endpoint.ever_refreshed? and (Time.now - endpoint.last_refreshed_at).abs < 1
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
