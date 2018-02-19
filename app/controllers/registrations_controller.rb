class RegistrationsController < Devise::RegistrationsController
  # skip default filter
  # https://github.com/plataformatec/devise/blob/master/app/controllers/devise/registrations_controller.rb
  skip_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  # only admins can create patient
  # TODO: as role added, only doctor+ can create patient
  before_filter :authenticate_admin!, :only => [ :new, :create, :cancel ]

  protected

  def after_sign_up_path_for(resource)
    if resource.is_a?(Patient)
      patient_url(resource)
    elsif resource.is_a?(Admin)
      admin_url(resource)
    else
      signed_in_root_path(resource)
    end
  end

  def after_update_path_for(resource)
     if resource.is_a?(Patient)
       patient_url(resource)
     elsif resource.is_a?(Admin)
       admin_url(resource)
     else
       signed_in_root_path(resource)
     end
  end

  def sign_up(resource_name, resoure)
    # just overwrite the default one
    # to prevent login as the new signup
  end

end
