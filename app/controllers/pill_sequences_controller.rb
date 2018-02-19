class PillSequencesController < ApplicationController
  before_filter :authenticate_admin_and_patient!, only: [:default, :show]
  before_filter :authenticate_admin!, except: [:default, :show]

  # GET /pill_sequenes
  # GET /pill_sequenes.json
  def index
    @sequences = PillSequence.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sequences }
      format.csv
    end
  end

  # GET /pill_sequences/default.json
  def default
    @sequence = PillSequence.pick_one

    respond_to do |format|
      format.html # default.html.erb
      format.json do
        render json: @sequence.to_json(
          include: {
            pill_sequence_steps: {
              only: [:name, :step_no, :meta]
            }
          })
      end
    end
  end

  # GET /pill_sequenes/1
  # GET /pill_sequenes/1.json
  def show
    @sequence = PillSequence.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json do
        render json: @sequence.to_json(
          include: {
            pill_sequence_steps: {
              only: [:name, :step_no, :meta]
            }
          })
      end
    end
  end

  # GET /pill_sequenes/new
  # GET /pill_sequenes/new.json
  def new
    @sequence = PillSequence.new
    @steps = [@sequence.pill_sequence_steps.build]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sequence }
    end
  end

  # GET /pill_sequenes/1/edit
  def edit
    @sequence = PillSequence.find(params[:id])
    @steps = @sequence.steps
  end

  # POST /pill_sequenes
  # POST /pill_sequenes.json
  def create
    @sequence = PillSequence.create(params[:pill_sequence])

    params[:pill_sequence_step].each do |step|
      @sequence.pill_sequence_steps.build(step)
    end

    respond_to do |format|
      if @sequence.save
        format.html { redirect_to @sequence,
                      notice: 'Recording sequence was successfully created.' }
        format.json { render json: @sequence,
                      status: :created,
                      location: @sequence }
      else
        format.html { render action: 'new' }
        format.json { render json: @sequence.errors,
                      status: :unprocessable_entity }
      end
    end
  end

  # PUT /pill_sequenes/1
  # PUT /pill_sequenes/1.json
  def update
    @sequence = PillSequence.find(params[:id])
    @steps = @sequence.steps

    params[:pill_sequence_step].each_with_index do |step, idx|
      if @steps[idx]
        @steps[idx].update_attributes(step)
      else
        @steps.create(step)
      end
    end

    # remove unused pill sequence steps
    diff = @steps.size - params[:pill_sequence_step].size
    @steps.destroy(@steps.last(diff)) if diff > 0

    respond_to do |format|
      if @sequence.update_attributes(params[:pill_sequence])
        format.html { redirect_to @sequence, notice: 'Recording sequence was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pill_sequenes/1
  # DELETE /pill_sequenes/1.json
  def destroy
    @sequence = PillSequence.find(params[:id])
    @sequence.destroy

    respond_to do |format|
      format.html { redirect_to pill_sequences_url }
      format.json { head :no_content }
    end
  end
end
