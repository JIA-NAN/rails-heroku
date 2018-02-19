class SessionsController < Devise::SessionsController
  layout "devise"

  before_filter :prevent_multiple_login, :only => [ :new ]
  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(:scope => resource_name,
                                         :recall => "#{controller_path}#failure")

    sign_in(resource_name, resource)

    if resource.is_a?(Patient)
      resource.ensure_authentication_token!
    end

    respond_to do |format|
      format.html { super }
      format.json {
        render json: {
                  type: 200,
                  result: { token: resource.authentication_token, data: resource }
               },
               status: :created
      }
    end
  end

  # return failure result
  def failure
    respond_to do |format|
      format.html {
        flash[:error] = t(:wrong_email_or_password)
        render action: "new"
      }
      format.json {
        render json: {
                 type: 422,
                 result: { error: t(:wrong_email_or_password) }
               },
               status: :unprocessable_entity
      }
    end
  end

  protected

  def prevent_multiple_login
    if admin_signed_in?
      redirect_to dashboard_url
    elsif patient_signed_in?
      redirect_to current_patient
    end
  end

end
