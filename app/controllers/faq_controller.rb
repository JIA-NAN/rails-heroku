class FaqController < ApplicationController
  before_filter :authenticate_admin_and_patient!, only: [:feedback]

  layout :layout_logged_in

  def help
  end

  def feedback
  end

  private

  def layout_logged_in
    if any_signed_in?
      'application'
    else
      'application_without_sidebar'
    end
  end
end
