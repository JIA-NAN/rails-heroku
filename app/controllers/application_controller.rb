class ApplicationController < ActionController::Base
  # FIXME temprory disable protect_from_fogery globally
  # the CSRF protection
  #protect_from_forgery

  skip_before_filter :verify_authenticity_token

  protected

  # determine a patient or an admin signed in
  def any_signed_in?
    admin_signed_in? || patient_signed_in? || false
  end

  # allow patient and admin to access
  def authenticate_admin_and_patient!
    if admin_signed_in?
      authenticate_admin!
    else
      authenticate_patient!
    end
  end

  # setup cancan default assumption
  def current_ability
    @current_ability ||= Ability.new(current_admin)
  end

  # devise sign in redirect
  def after_sign_in_path_for(resource)
    if resource.is_a?(Patient)
      root_url
    elsif resource.is_a?(Admin)
      dashboard_url
    else
      super
    end
  end
end
