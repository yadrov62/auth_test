class ApplicationController < ActionController::Base
  # Protect from forgery with exception
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  # Make auth helper methods available to views
  helper_method :current_user, :user_signed_in?

  private
end

