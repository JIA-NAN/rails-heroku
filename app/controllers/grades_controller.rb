class GradesController < ApplicationController
  before_filter :authenticate_admin!

  def index
    respond_to do |format|
      format.html { redirect_to controller: :records, action: 'index' }
      format.json { render text: 'no index page' }
      format.csv
    end
  end

  def create
    @grade = current_admin.grades.create(params[:grade])
    respond_to do |format|
      if @grade.save
        format.html { redirect_to @grade.record, notice: 'Grade was successfully created.' }
        format.json { render json: @grade.record, status: :created, location: @grade.record }
      else
        format.html { redirect_to @grade.record }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @grade = Grade.find(params[:id])

    respond_to do |format|
      if @grade.update_attributes(params[:grade])
        format.html { redirect_to @grade.record, notice: 'Grade was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_patient_record_path(@grade.record) }
        format.json { render json: @grade.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @grade = Grade.find(params[:id])
    @grade.destroy

    respond_to do |format|
      format.html { redirect_to @grade.record }
      format.json { head :no_content }
    end
  end

end
