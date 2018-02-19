class HomeController < ApplicationController
  before_filter :authenticate!

  def index
    # get the patient's schedule
    #@schedule = current_patient.current_schedule
    # get the next record to submit
    #@pill_time = current_patient.current_pill_time
    # get the latest doctor feedback if any
    #@grade = current_patient.grades.with_comment.this_week.last

    # (1) no schedule
    #     -> @schedule == nil
    # (2) no pill record now
    #     -> @pill_time == nil
    # (3) to submit a record
    #     -> @pill_time != nil

    #if @pill_time # case (3)
    #  @record = current_patient.records.build
    #  @sequence = PillSequence.pick_one
    #else # case (2)
    #  @records = current_patient.records.includes(:grade).from_today
    #  @next_pill = @schedule && @schedule.future_pill_time
    #end

    # mark any missed records
    #MissingRecordChecker.mark_missed_record(current_patient)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: { current_pill: @pill_time, next_pill: @next_pill } }
    end
  end

  protected

  # admin signed in go dashboard
  def authenticate!
    if admin_signed_in?
      redirect_to dashboard_url
    else
      authenticate_admin!
    end
  end

end
