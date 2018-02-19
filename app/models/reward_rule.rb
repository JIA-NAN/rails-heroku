# This is a singleton class
class RewardRule < ActiveRecord::Base
  attr_accessible :num_of_days, :reward
  before_create :confirm_singularity

  private

  def confirm_singularity
    raise Exception.new("There can be only one reward rule per installation.") if RewardRule.count > 0
  end

  def self.rule
    first
  end
end
