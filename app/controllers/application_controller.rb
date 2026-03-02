class ApplicationController < ActionController::Base
  # Protect from forgery with exception
  protect_from_forgery with: :exception

  before_action :authenticate_user!, unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :forbidden }
      format.any  { head :forbidden }
    end
  end
  # Make auth helper methods available to views
  helper_method :current_user, :user_signed_in?

  private
end

