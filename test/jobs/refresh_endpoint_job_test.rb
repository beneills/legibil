require 'test_helper'

class RefreshEndpointJobTest < ActiveJob::TestCase

  # negative tests

   test "bad endpoints raises error" do
    [
      "bad url",
      "",
      " "
    ].each do |url|
      # Should fail, swallow the error, and print to log
      endpoint = Endpoint.new({ name: "bad endpoint", url: url, user: users(:chef) })
      RefreshEndpointJob.perform_now endpoint
    end
  end

  # positive tests

  test "endpoint last refresh time is updated" do
    assert_not refreshed_recently?(endpoints(:cook))

    RefreshEndpointJob.perform_now endpoints(:cook)

    assert refreshed_recently?(endpoints(:cook))
  end
end
