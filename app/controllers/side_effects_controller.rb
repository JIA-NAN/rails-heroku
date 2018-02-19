class SideEffectsController < ApplicationController
  before_filter :authenticate_admin_and_patient!, only: [:index]
  before_filter :authenticate_admin!, except: [:index]

  # GET /side_effects
  # GET /side_effects.json
  def index
    @side_effects = SideEffect.all

    respond_to do |format|
      format.html # index.html.erb
      format.json do
        if params.key?(:key) && ['updated_at'].include?(params[:key])
          render json: @side_effects, only: params[:key]
        else
          render json: @side_effects
        end
      end
    end
  end

  # GET /side_effects/1
  # GET /side_effects/1.json
  def show
    @side_effect = SideEffect.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @side_effect }
    end
  end

  # GET /side_effects/new
  # GET /side_effects/new.json
  def new
    @side_effect = SideEffect.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @side_effect }
    end
  end

  # GET /side_effects/1/edit
  def edit
    @side_effect = SideEffect.find(params[:id])
  end

  # POST /side_effects
  # POST /side_effects.json
  def create
    @side_effect = SideEffect.new(params[:side_effect])

    respond_to do |format|
      if @side_effect.save
        format.html { redirect_to @side_effect, notice: 'Side effect was successfully created.' }
        format.json { render json: @side_effect, status: :created, location: @side_effect }
      else
        format.html { render action: "new" }
        format.json { render json: @side_effect.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /side_effects/1
  # PUT /side_effects/1.json
  def update
    @side_effect = SideEffect.find(params[:id])

    respond_to do |format|
      if @side_effect.update_attributes(params[:side_effect])
        format.html { redirect_to @side_effect, notice: 'Side effect was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @side_effect.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /side_effects/1
  # DELETE /side_effects/1.json
  def destroy
    @side_effect = SideEffect.find(params[:id])
    @side_effect.destroy

    respond_to do |format|
      format.html { redirect_to side_effects_url }
      format.json { head :no_content }
    end
  end
end
