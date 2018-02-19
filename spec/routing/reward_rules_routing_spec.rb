require "rails_helper"

RSpec.describe RewardRulesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/reward_rules").to route_to("reward_rules#index")
    end

    it "routes to #new" do
      expect(:get => "/reward_rules/new").to route_to("reward_rules#new")
    end

    it "routes to #show" do
      expect(:get => "/reward_rules/1").to route_to("reward_rules#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/reward_rules/1/edit").to route_to("reward_rules#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/reward_rules").to route_to("reward_rules#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/reward_rules/1").to route_to("reward_rules#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/reward_rules/1").to route_to("reward_rules#destroy", :id => "1")
    end

  end
end
