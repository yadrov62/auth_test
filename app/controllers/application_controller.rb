class ApplicationController < ActionController::Base
  # Protect from forgery with exception
  protect_from_forgery with: :exception

  # Make auth helper methods available to views
  helper_method :current_user, :user_signed_in?

  private

  # ===========================================
  # DEVISE/CANCANCAN READINESS PLACEHOLDERS
  # ===========================================
  # These stub methods will be replaced by Devise.
  # They allow views and controllers to reference
  # authentication methods without breaking.
  # ===========================================

  # Stub: Returns the currently signed-in user
  # Devise will replace this with the actual current_user
  def current_user
    # TODO: Devise will provide the real implementation
    nil
  end

  # Stub: Returns true if a user is signed in
  # Devise will replace this with the actual user_signed_in?
  def user_signed_in?
    # TODO: Devise will provide the real implementation
    false
  end

  # Stub: Redirects to login if not authenticated
  # Devise will replace this with the actual authenticate_user!
  def authenticate_user!
    # TODO: Devise will provide the real implementation
    unless user_signed_in?
      flash[:alert] = "You need to sign in or sign up before continuing."
      redirect_to login_path
    end
  end
end

