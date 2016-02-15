module WelcomeHelper
  def last_refreshed_ago(endpoint)
    return "error: never refreshed" unless endpoint.ever_successfully_refreshed?

    seconds        = Time.now.to_f - endpoint.last_refreshed_at.to_f
    seconds_approx = seconds.to_i

    "#{seconds_approx} seconds"
  end
end
