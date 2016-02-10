# A submission to the refresh worker queue, passed as argument to worker.
#
# Includes endpoint ID and submission time.
#
class RefreshSubmission

  attr_accessor :endpoint_id

  def endpoint
    @endpoint || Endpoint.find(@endpoint_id)
  end

  # Is this submission valid?  i.s. is there anything to do?
  #
  # Used to guarantee idempotence.
  def valid?
    not invalid?
  end

  def to_json(options={})
    { 'endpoint_id' => @endpoint_id, 'submission_time' => @submission_time}.to_json
  end

  def self.from_h(hash)
    self.new hash['endpoint_id'], hash['submission_time']
  end

  # Create submission with particular endpoint id and current time
  def initialize(endpoint_id, submission_time=nil)
    @endpoint_id     = endpoint_id
    @submission_time = submission_time || Time.now.to_f
  end

  private

  # The sumbission R should not be processed under the following circumstances:
  #
  #   1)     R  < S  < t      (job retry post-success)
  #   2)     R  < F  < t      (job retry post-failure)
  #   3) i)  R1 < R  < S1 < t (quick successive requests)
  #      ii) R  < R1 < S1
  #
  # where:
  #   t = time now
  #   R = refresh request
  #   S = refresh success
  #   F = refresh failure
  #
  def invalid?
    # Endpoint no longer exists in database
    endpoint.nil? or

      # Guard against (1) and (3)
      ( endpoint.ever_successfully_refreshed? and @submission_time < endpoint.last_refreshed_at.to_f ) or

      # Guard against (2)
      ( endpoint.refresh_ever_failed? and @submission_time < endpoint.last_refresh_failure_at.to_f )
  end
end