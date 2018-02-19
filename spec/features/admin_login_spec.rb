require 'rails_helper'

RSpec.describe 'Admin Login System', :type => :feature do
  before :each do
    @admin = create(:admin, email: 'admin@admin.com')
  end

  describe 'Logging In' do
    it 'should logged in after enters correct email and password' do
      admin_login('admin@admin.com', 'adminadmin')
      expect(current_path).to eq(dashboard_path)
      expect(page).to have_content('Signed in successfully.')
    end

    it 'cannot log in if enters wrong email' do
      admin_login('admin@admin.co', 'adminadmin')
      expect(current_path).to eq(new_admin_session_path)
      expect(page).to have_content('Wrong email or password.')
    end

    it 'cannot log in if enters wrong password' do
      admin_login('admin@admin.co', 'adminadmin')
      expect(current_path).to eq(new_admin_session_path)
      expect(page).to have_content('Wrong email or password.')
    end
  end

  describe 'Logging Out' do
    before :each do
      admin_login('admin@admin.com', 'adminadmin')
    end

    it 'should logged out system' do
      click_on 'Logout'
      expect(current_path).to eq(new_patient_session_path)
    end
  end
end
