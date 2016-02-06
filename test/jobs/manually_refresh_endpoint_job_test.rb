require 'test_helper'

class ManuallyRefreshEndpointJobTest < ActiveJob::TestCase
  test "endpoint last refresh time is updated" do
    assert_not refreshed_recently?(endpoints(:cook))

    ManuallyRefreshEndpointJob.perform_now endpoints(:cook)

    assert refreshed_recently?(endpoints(:cook))
  end
end
