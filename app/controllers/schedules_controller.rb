class SchedulesController < ApplicationController
  before_filter :authenticate_admin_and_patient!, only: [:index, :show]
  before_filter :authenticate_admin!, except: [:index, :show]

  # GET /schedules
  # GET /schedules.json
  def index
    current_patient ||= Patient.find(params[:patient_id])

    if params.key?(:all) && params[:all] == '1'
      @schedules = current_patient.schedules
    else
      @schedules = [current_patient.current_schedule]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json do
        if params.key?(:key) && ['updated_at', 'started_at', 'terminated_at'].include?(params[:key])
          render json: @schedules.map { |s| s.as_json(only: params[:key]) }
        else
          render json: @schedules.to_json(include: [:pill_times])
        end
      end
      format.csv
    end
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
    @schedule = Schedule.includes(:pill_times).find(params[:id])
    @patient = @schedule.patient
    @statistic = SchedulePresenter.new(@schedule)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @schedules }
    end
  end


  # GET /schedules/new
  # GET /schedules/new.json
  def new
    @patient = Patient.find(params[:patient_id])
    current_schedule = @patient.current_schedule
    if current_schedule
        current_schedule.terminated_at = Date.today
        current_schedule.save
    end
    @schedule = @patient.schedules.build
    @pill_times = [@schedule.pill_times.build]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @schedule }
    end
  end

  # GET /schedules/1/edit
  def edit
    @patient = Patient.find(params[:patient_id])
    @schedule = @patient.schedules.find(params[:id])
    @pill_times = @schedule.pill_times
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @patient = Patient.find(params[:patient_id])
    @schedule = @patient.schedules.create(params[:schedule])

    # TODO can improve it to use nested attributes
    params[:pill_time].each do |pill_time|
      @schedule.pill_times.build(pill_time)
    end

    @pill_times = @schedule.pill_times

    respond_to do |format|
      if @schedule.save
        format.html { redirect_to [@patient, @schedule],
                      notice: 'Schedule was successfully created.' }
        format.json { render json: @schedule,
                      status: :created,
                      location: [@patient, @schedule] }
      else
        format.html { render action: "new" }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /schedules/1
  # PUT /schedules/1.json
  def update
    @patient = Patient.find(params[:patient_id])
    @schedule = @patient.schedules.find(params[:id])
    @pill_times = @schedule.pill_times

    # TODO can improve it to use nested attributes
    if params[:pill_time]
      params[:pill_time].each_with_index do |pill_time, idx|
        if @pill_times[idx]
          @pill_times[idx].update_attributes(pill_time)
        else
          @pill_times.create(pill_time)
        end
      end
    end

    # remove unused pill times
    if params[:pill_time]
      diff = @pill_times.size - params[:pill_time].size
      @pill_times.destroy(@pill_times.last(diff)) if diff > 0
    end

    respond_to do |format|
      if @schedule.update_attributes(params[:schedule])
        format.html { redirect_to [@patient, @schedule],
                      notice: 'Schedule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @schedule.errors,
                      status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    @schedule = Schedule.find(params[:id])
    @schedule.destroy

    respond_to do |format|
      format.html { redirect_to @schedule.patient }
      format.json { head :no_content }
    end
  end
end
