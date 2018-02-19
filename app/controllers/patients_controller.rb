class PatientsController < ApplicationController
  before_filter :authenticate_admin_and_patient!, only: [:show]
  before_filter :authenticate_admin!, only: [:index, :destroy, :edit]
  before_filter :authenticate_patient!, only: [:show_calendar]

  # GET /patients
  # GET /patients.json
  def index
    @filter = FilterPresenter.new(['active', 'all'], 'all')
    @filter.current = params[:filter]
    @active_patients = Patient.state(@filter.active)
                       .order('created_at DESC')
                       #.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @active_patients }
      format.csv {send_data @active_patients.to_csv}
      format.xls # {send_data @patients.to_csv(col_sep: "\t")}
    end
  end

  # GET /patients/1
  # GET /patients/1.json
  def show
    @patient = Patient.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @patient }
    end
  end

  def record

    @patient = Patient.find(params[:id])

    @day = Date.parse(params[:date]).beginning_of_day

    puts @day 

    @record = @patient.records.where("pill_time_at >= ? AND pill_time_at < ?", @day, 1.day.from_now(@day))

    respond_to do |format|
      format.html # record.html.erb
      format.json { render json: @patient }
    end

  end 

  # GET /patients/1/edit
  def edit
    @patient = Patient.find(params[:id])
  end

  # PUT /patients/1
  # PUT /patients/1.json
  def update
    @patient = Patient.find(params[:id])

    respond_to do |format|
      if @patient.update_attributes(params[:patient])
        format.html { redirect_to @patient, notice: 'Patient was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /patients/1
  # DELETE /patients/1.json
  def destroy
    @patient = Patient.find(params[:id])
    @patient.destroy

    respond_to do |format|
      format.html { redirect_to patients_url }
      format.json { head :no_content }
    end
  end

  def show_calendar
    cp = current_patient
    @ap = AdherencePresenter.new(cp)
    month = params[:month].to_i
    year = params[:year].to_i
    date = Date.new(year, month, 1)
    @start_date = date - date.wday
    @end_date = date.end_of_month + (7 - date.end_of_month.wday)
    respond_to do |format|
      format.json {render}
    end
  end

  def invoices

    @patient = Patient.find(params[:patient_id])

    respond_to do |format|
      format.html
    end

  end 

  def reports

    @patient = Patient.find(params[:patient_id])

    respond_to do |format|
      format.html
    end

  end 



  def wallets
    @patients = Patient.order('created_at DESC')
                       #.page(params[:page])

    respond_to do |format|
      format.html
    end
  end
end
