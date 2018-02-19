require 'rails_helper'

RSpec.describe "RewardRules", :type => :request do
  describe "GET /reward_rules" do
    it "works! (now write some real specs)" do
      get reward_rules_path
      expect(response).to have_http_status(200)
    end
  end
end
