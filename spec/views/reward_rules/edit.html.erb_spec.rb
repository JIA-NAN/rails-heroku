require 'rails_helper'

RSpec.describe "reward_rules/edit", :type => :view do
  before(:each) do
    @reward_rule = assign(:reward_rule, RewardRule.create!(
      :num_of_days => 1,
      :reward => "9.99"
    ))
  end

  it "renders the edit reward_rule form" do
    render

    assert_select "form[action=?][method=?]", reward_rule_path(@reward_rule), "post" do

      assert_select "input#reward_rule_num_of_days[name=?]", "reward_rule[num_of_days]"

      assert_select "input#reward_rule_reward[name=?]", "reward_rule[reward]"
    end
  end
end
