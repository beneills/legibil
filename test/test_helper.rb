ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup :ensure_rails_tmp_exists

  def refreshed_recently?(endpoint)
    endpoint.ever_refreshed? and (Time.now - endpoint.last_refreshed_at).abs < 1
  end

  private

  def ensure_rails_tmp_exists
    rails_tmp = Rails.root.join('tmp')
    Dir.mkdir(rails_tmp) unless File.exists?(rails_tmp)
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
