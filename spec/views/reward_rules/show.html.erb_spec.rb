require 'rails_helper'

RSpec.describe "reward_rules/show", :type => :view do
  before(:each) do
    @reward_rule = assign(:reward_rule, RewardRule.create!(
      :num_of_days => 2,
      :reward => "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/9.99/)
  end
end
