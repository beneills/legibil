class WelcomeController < ApplicationController
  def contact
  end

  def help
  end

  def index
    @new_endpoint = Endpoint.new
    @endpoints    = if user_signed_in?
                      current_user.endpoints
                    else
                      []
                    end
  end

  def legal
  end

  def profile
  end
end
