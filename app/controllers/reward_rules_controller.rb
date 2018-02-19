class RewardRulesController < ApplicationController
  # GET /reward_rules
  # GET /reward_rules.json
  def index
    # RewardRule is a singleton.
    # If no rule exists, redirect to create new rule,
    # else redirect_to show

    if RewardRule.count == 0
      new
    else
      show
    end
  end

  # GET /reward_rules/1
  # GET /reward_rules/1.json
  def show
    if RewardRule.count == 0
      create
    else
      @reward_rule = RewardRule.first
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @reward_rule }
      end
    end
  end

  # GET /reward_rules/new
  # GET /reward_rules/new.json
  def new
    @reward_rule = RewardRule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @reward_rule }
    end
  end

  # GET /reward_rules/1/edit
  def edit
    @reward_rule = RewardRule.find(params[:id])
  end

  # POST /reward_rules
  # POST /reward_rules.json
  def create
    @reward_rule = RewardRule.new(params[:reward_rule])

    respond_to do |format|
      if @reward_rule.save
        format.html { redirect_to @reward_rule, notice: 'Reward rule was successfully created.' }
        format.json { render json: @reward_rule, status: :created, location: @reward_rule }
      else
        format.html { render action: "new" }
        format.json { render json: @reward_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reward_rules/1
  # PUT /reward_rules/1.json
  def update
    @reward_rule = RewardRule.find(params[:id])

    respond_to do |format|
      if @reward_rule.update_attributes(params[:reward_rule])
        format.html { redirect_to @reward_rule, notice: 'Reward rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @reward_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reward_rules/1
  # DELETE /reward_rules/1.json
  def destroy
    @reward_rule = RewardRule.find(params[:id])
    @reward_rule.destroy

    respond_to do |format|
      format.html { redirect_to reward_rules_url }
      format.json { head :no_content }
    end
  end
end
