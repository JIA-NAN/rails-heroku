require 'rails_helper'

RSpec.describe "reward_rules/new", :type => :view do
  before(:each) do
    assign(:reward_rule, RewardRule.new(
      :num_of_days => 1,
      :reward => "9.99"
    ))
  end

  it "renders new reward_rule form" do
    render

    assert_select "form[action=?][method=?]", reward_rules_path, "post" do

      assert_select "input#reward_rule_num_of_days[name=?]", "reward_rule[num_of_days]"

      assert_select "input#reward_rule_reward[name=?]", "reward_rule[reward]"
    end
  end
end
