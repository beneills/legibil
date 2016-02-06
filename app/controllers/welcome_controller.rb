class WelcomeController < ApplicationController
  def index
    @new_endpoint = Endpoint.new
    @endpoints    = if user_signed_in?
                      current_user.endpoints
                    else
                      []
                    end
  end
end
