class ApplogsController < ApplicationController
  before_filter :authenticate_admin_and_patient!, only: [:create]
  before_filter :authenticate_admin!, except: [:create]

  # GET /applogs
  # GET /applogs.json
  def index
    @filter_list = ['all'].concat(Applog::LEVELS)

    if @filter_list.include?(params[:filter])
      @active_filter = params[:filter]
    else
      @active_filter = 'all'
    end

    @applogs = Applog.level(@active_filter).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @applogs }
    end
  end

  # GET /applogs/1
  # GET /applogs/1.json
  def show
    @filter_list = ['all'].concat(Applog::LEVELS)

    if @filter_list.include?(params[:filter])
      @active_filter = params[:filter]
    else
      @active_filter = 'all'
    end

    @applogs = Applog.where(identifier: params[:id])
                     .level(@active_filter)
                     .page(params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @applog }
    end
  end

  # GET /applogs/new
  # GET /applogs/new.json
  def new
    @applog = Applog.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @applog }
    end
  end

  # GET /applogs/1/edit
  def edit
    @applog = Applog.find(params[:id])
  end

  # POST /applogs
  # POST /applogs.json
  def create
    @applog = Applog.new(params[:applog])

    respond_to do |format|
      if @applog.save
        format.html { redirect_to @applog, notice: 'Applog was successfully created.' }
        format.json { render json: @applog, status: :created, location: @applog }
      else
        format.html { render action: "new" }
        format.json { render json: @applog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /applogs/1
  # PUT /applogs/1.json
  def update
    @applog = Applog.find(params[:id])

    respond_to do |format|
      if @applog.update_attributes(params[:applog])
        format.html { redirect_to @applog, notice: 'Applog was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @applog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applogs/1
  # DELETE /applogs/1.json
  def destroy
    @applog = Applog.find(params[:id])
    @applog.destroy

    respond_to do |format|
      format.html { redirect_to applogs_url }
      format.json { head :no_content }
    end
  end
end
