require 'sidekiq/testing'
require 'test_helper'

class RefreshEndpointWorkerTest < ActiveJob::TestCase
  test "endpoint last refresh time is updated" do
    Sidekiq::Testing.inline! do
      assert_not refreshed_recently? endpoints(:cook)

      cook_id = endpoints(:cook).id

      RefreshEndpointWorker.perform_async RefreshSubmission.new(cook_id)

      # It's not clear to me why reloading is necessary...
      cook_endpoint = Endpoint.find cook_id
      assert refreshed_recently? cook_endpoint
    end
  end
end
