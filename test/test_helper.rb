require 'coveralls'
Coveralls.wear! 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'sidekiq/testing'

# Prevent Sidekiq spewing stuff to stdout during test
Sidekiq::Logging.logger = nil

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup :ensure_rails_tmp_exists

  def refresh_requested_recently?(endpoint)
    endpoint.request_ever_requested? and (Time.now - endpoint.last_refresh_request_at).abs < 1
  end

  def refreshed_recently?(endpoint)
    endpoint.ever_successfully_refreshed? and (Time.now - endpoint.last_refreshed_at).abs < 1
  end

  def refresh_failed_recently?(endpoint)
    endpoint.refresh_ever_failed? and (Time.now - endpoint.last_refresh_failure_at).abs < 1
  end

  def endpoint_data(identifier = '')
    { name: "my endpoint#{identifier}", url: "http://example.com/endpoint#{identifier}" }
  end

  private

  def ensure_rails_tmp_exists
    rails_tmp = Rails.root.join('tmp')
    Dir.mkdir(rails_tmp) unless File.exists?(rails_tmp)
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
  include ActiveJob::TestHelper
end
