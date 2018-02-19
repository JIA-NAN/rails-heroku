require 'rails_helper'

RSpec.describe 'Admin on Administrative Stuffs', :type => :feature do
  before :each do
    @admin = create(:admin, email: 'admin@admin.com')
    admin_login('admin@admin.com', 'adminadmin')
  end

  describe 'Admin can view opening submission window' do
    it 'view an empty list when no patients on submission' do
      visit submission_path
      expect(page).to have_content('No patient has submission window open')
    end

    it 'view one patient on submission' do
      create(:pill_time, Ptime.weekday_today => Ptime.to_ptime(Time.zone.now))

      visit submission_path
      expect(page).to have_content('100001')
    end
  end
end
