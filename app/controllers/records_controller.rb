class RecordsController < ApplicationController
  before_filter :authenticate_admin_and_patient!, only: [:index, :show, :update]
  before_filter :authenticate_patient!, only: [:create]
  before_filter :authenticate_admin!, except: [:index, :create, :show, :update, :upload_video, :process_video]

  # GET /records
  # GET /records.json
  def index
    @received_filter = FilterPresenter.new(['true', 'false'], 'all')
    @received_filter.current = params[:received]
    @graded_filter = FilterPresenter.new(['true', 'false'], 'all')
    @graded_filter.current = params[:graded]
    @patient = if patient_signed_in?
                 current_patient
               elsif params[:patient_id]
                 Patient.find(params[:patient_id])
               end
	graded_flag = (@graded_filter.active == 'true')
	received_flag = (@received_filter.active == 'true')

	if @graded_filter.active == 'all' and @received_filter.active == 'all'
		@records = (@patient ? @patient.records : Record.includes(:patient)).includes(:grade).order('created_at DESC')#.page(params[:page])
	elsif @graded_filter.active == 'all'
		@records = (@patient ? @patient.records : Record.includes(:patient)).includes(:grade).where(received: received_flag).order('created_at DESC')#.page(params[:page])
	elsif @received_filter.active == 'all'
		@records = (@patient ? @patient.records : Record.includes(:patient)).includes(:grade).where(graded: graded_flag).order('created_at DESC')#.page(params[:page])
	else
		@records = (@patient ? @patient.records : Record.includes(:patient)).includes(:grade).where(graded: graded_flag, received: received_flag).order('created_at DESC')#.page(params[:page])
	end

    respond_to do |format|
      format.html # index.html.erb
      format.json do
        render json: @records.to_json(
          include: {
            grade: {
              only: [:grade, :comment]
            }
          },
          only: [:id, :device, :comment, :status, :patient_id,
                 :created_at, :updated_at, :meta, :pill_time_at, :received],
          methods: [:is_excuse?])
      end
      format.csv
    end
  end

  # GET /records/1
  # GET /records/1.json
  def show
    @record = find_record
    respond_to do |format|
      format.html # show.html.erb
      format.json do
        render json: @record.to_json(
          include: {
            grade: {
              except: [:note]
            }
          },
          methods: [:is_excuse?])
      end
    end
  end

  # GET /records/new
  # GET /records/new.json
  def new
    @patient = Patient.find(params[:patient_id])
    @record = @patient.records.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @record }
    end
  end

  # GET /records/1/edit
  def edit
    @record = find_record
    @grade  = @record.grade
  end

  # POST /records
  # POST /records.json
  def create
    # to support array meta from iOS
    if params[:record][:meta].is_a? Array
      params[:record][:meta] = params[:record][:meta].join(",")
    end

    @record = current_patient.records.new(params[:record])

    @record.actual_pill_time_at = Time.zone.parse(params[:record][:actual_pill_time_at])


    respond_to do |format|
      if @record.save
        if @record.is_android_phone
          @record.swapUVAttribute
        end
        # if Rails.env == 'production'
        #   @record.delay.post_processing
        # else
        #   @record.post_processing
        # end
        format.json { render json: @record,
                             status: :created,
                             location: [current_patient, @record] }

        format.html { redirect_to [current_patient, @record],
                      notice: 'Record was successfully created.' }
      else
        puts @record.errors
        format.json { render json: @record.errors, status: :unprocessable_entity }
        format.html { render action: 'new' }
      end
    end
  end

  #POST /records/1/process
  def process_video
    @record = find_record
    @record.process_video
    respond_to do |format|
      format.html { render action: 'show' }
    end
  end

  #POST /records/1/upload_video
  def upload_video
    @record = find_record
    @record.update_attributes(params[:record])
    puts "record#{@record}"
    if @record.save
      #@record.delay.post_processing
      #if Rails.env == 'production'
      #else
      #  @record.post_processing
      #end
      render json: @record,status: :created, location: [current_patient, @record]
    else
      render json: @record.errors, status: :unprocessable_entity
    end
  end

  # PUT /records/1
  # PUT /records/1.json
  def update
    @record = find_record

    respond_to do |format|
      if @record.update_attributes(params[:record])
        format.html { redirect_to [@record.patient, @record],
                      notice: 'Record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'show' }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    @record = find_record
    @record.destroy

    respond_to do |format|
      format.html { redirect_to records_url }
      format.json { head :no_content }
      format.js # destroy.js
    end
  end

  private

  def find_record
    if admin_signed_in?
      Record.find(params[:id])
    else
      current_patient.records.find(params[:id])
    end
  end

end
