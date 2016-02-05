class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
    def forbid_non_users
      unless user_signed_in?
        respond_to do |format|
          format.html { head :forbidden }
          format.json { head :forbidden }
        end
      end
    end
end
