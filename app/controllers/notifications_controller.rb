class NotificationsController < ApplicationController
  before_filter :authenticate_admin!

  # GET /notifications
  # GET /notifications.json
  def index
    @filter = FilterPresenter.new(['waiting', 'all'], 'waiting')
    @filter.current = params[:filter]
    @notifications = Notification.order('send_at DESC')
                                 .page(params[:page])
                                 .send(@filter.active)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notificationss }
    end
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
    @notification = Notification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @notification }
    end
  end

  # GET /notifications/new
  # GET /notifications/new.json
  def new
    # TODO support multiple receivers
    @notification = Notification.new(patient_id: params[:to])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @notification }
    end
  end

  # GET /notifications/1/edit
  def edit
    @notification = Notification.find(params[:id])
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @service = NotificationService.find(params[:notification][:notification_service_id])
    @notification = @service.notifications.new(params[:notification])

    respond_to do |format|
      if @notification.save
        format.html { redirect_to @notification,
                      notice: 'Notification was successfully created.'  }
        format.json { render json: @notification,
                             status: :created,
                             location: @notification }
      else
        format.html { render action: 'new' }
        format.json { render json: @notification.errors,
                             status: :unprocessable_entity }
      end
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.json
  def update
    @notification = Notification.find(params[:id])

    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        format.html { redirect_to @notification,
                      notice: 'Notification was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @notification.errors,
                             status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to(notifications_url) }
      format.json { head :no_content }
    end
  end

end
