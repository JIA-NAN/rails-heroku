require 'rails_helper'

RSpec.describe "reward_rules/index", :type => :view do
  before(:each) do
    assign(:reward_rules, [
      RewardRule.create!(
        :num_of_days => 2,
        :reward => "9.99"
      ),
      RewardRule.create!(
        :num_of_days => 2,
        :reward => "9.99"
      )
    ])
  end

  it "renders a list of reward_rules" do
    render
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
  end
end
