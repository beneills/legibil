class WelcomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @new_endpoint = Endpoint.new
    @endpoints    = current_user.endpoints
  end
end
