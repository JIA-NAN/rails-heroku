class AdminsController < ApplicationController
  before_filter :authenticate_admin!

  # GET /admins
  # GET /admins.json
  def index
    @admins = Admin.order('created_at DESC').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admins }
    end
  end

  # GET /admins/1
  # GET /admins/1.json
  def show
    @admin = Admin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin }
    end
  end

end
