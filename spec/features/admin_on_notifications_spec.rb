require 'rails_helper'

RSpec.describe 'Admin on Notifications', :type => :feature do
  before :each do
    @sms = create(:service_sms)
    @push = create(:service_push)

    @admin = create(:admin, email: 'admin@admin.com')
    @patient = create(:patient)

    admin_login('admin@admin.com', 'adminadmin')
  end

  describe 'Send notification from patient#show' do
    it 'should see send notification on patient#show' do
      visit patient_path(@patient)
      expect(page).to have_content('Send Notification')
    end

    it 'should goto notification#new' do
      visit patient_path(@patient)
      click_link 'Send Notification'

      expect(current_path).to eq(new_notification_path)
    end
  end

  describe 'Create a notification' do
    it 'should create a notification' do
      visit new_notification_path

      within '#new_notification' do
        fill_in 'To Patient', with: @patient.id
        fill_in 'Message', with: 'hello testing'
      end

      click_on 'Create Notification'

      expect(current_path).to eq(notification_path(1))
      expect(page).to have_content(@patient.phone)
      expect(page).to have_content('hello testing')
    end

    it 'should view notifications' do
      n = create(:notification, notification_service_id: @sms.id)

      visit notifications_path

      expect(page).to have_content(n.fullname)
    end
  end
end
