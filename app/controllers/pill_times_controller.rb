class PillTimesController < ApplicationController
  before_filter :authenticate_patient!

  # GET /pill_times
  # GET /pill_times.json
  def index
    @schedule = current_patient.current_schedule
    @pill_time = current_patient.current_pill_time
    @next_pill = @schedule && @schedule.future_pill_time
    @pill_count = @schedule && @schedule.pill_times.size
    @record_count = current_patient.records.from_today.size

    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.json {
        render json: {
          current_pill: @pill_time,
          next_pill: @next_pill,
          records_submited: @record_count,
          pills_required: @pill_count,
          schedule: @schedule
        }
      }
      format.csv
    end
  end

end
