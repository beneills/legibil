class ManuallyRefreshEndpointJob < ActiveJob::Base
  queue_as :urgent

  def perform(endpoint)
    logger.debug "refreshing endpoint #{endpoint.url} by user #{endpoint.user.email}"

    # update refresh time
    endpoint.last_refreshed_at = Time.now
    unless endpoint.save
      logger.error "could not save updated refresh time for endpoint #{endpoint.id}"
    end
  end
end
