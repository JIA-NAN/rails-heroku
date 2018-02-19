class DashboardController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @pending_records = Record.where(received: true, graded: false)
    @missing_records = Record.where(received: false, graded: false)
    @pending_records_count = @pending_records.length
    @missing_records_count = @missing_records.length

    @pending_records = @pending_records.take(5)
    @missing_records = @missing_records.take(5)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @records }
    end
  end

  def submission
    @patients = Patient.with_active_schedule.select { |p| p.current_pill_time }

    respond_to do |format|
      format.html # submission.html.erb
      format.json { render json: @patients }
    end
  end

  def grade
    @sequences = PillSequence.all
    @sequence  = find_sequence @sequences, params[:id].to_i

    if @sequence
      @records = Record.where(received: true, graded: false)
                          .paginate(page: params[:page], per_page: 6)
    end

    respond_to do |format|
      format.html # grade.html.erb
      format.json { render json: @records }
    end
  end

  def additional_info
    @unprocessed_records = Record.where(video_processing: true).take(10)
    @tasks = WheneverTask.all

    respond_to do |format|
      format.html # additional_info.html.erb
    end
  end

  def key
    

    respond_to do |format|

        format.json { render :json => {:key => ENV.fetch('CIPHER_KEY') {"key not set in environment" } }  }
      
    end
  end

  private

  def find_sequence(seqs, id)
    if seqs.empty?
      nil
    else
      seqs.find { |s| s.id == id } || seqs[0]
    end
  end

end
