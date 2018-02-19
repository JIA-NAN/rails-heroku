require 'rails_helper'

RSpec.describe "alerts/edit", :type => :view do
  before(:each) do
    @alert = assign(:alert, Alert.create!())
  end

  it "renders the edit alert form" do
    render

    assert_select "form[action=?][method=?]", alert_path(@alert), "post" do
    end
  end
end
