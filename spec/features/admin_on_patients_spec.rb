require 'rails_helper'

RSpec.describe 'Admin on Patients', :type => :feature do
  before :each do
    create(:service_sms)
    create(:service_push)

    create(:admin, email: 'admin@admin.com')

    admin_login('admin@admin.com', 'adminadmin')
  end

  describe 'Creating a Patient Account' do
    before :each do
      visit new_patient_registration_path
    end

    it 'should see auto generated passwords' do
      pwd  = find('#patient_password').value
      pwd2 = find('#patient_password_confirmation').value

      expect(pwd).to match(/\w{8,}/)
      expect(pwd2).to eq(pwd)
    end

    it 'should direct to account page after create' do
      within '#new_patient' do
        fill_in 'Firstname', with: 'First'
        fill_in 'Lastname', with: 'Last'
        fill_in 'Email', with: 'email@email.com'
      end

      click_on 'Create'

      expect(current_path).to eq(patient_path(1))
      expect(page).to have_content('email@email.com')
      expect(page).to have_content('100001')
    end

    it 'should direct to account page after create (more info provided)' do
      within '#new_patient' do
        fill_in 'Firstname', with: 'First'
        fill_in 'Lastname', with: 'Last'
        fill_in 'Phone', with: '+6512345678'
        fill_in 'Email', with: 'email@email.com'
        check 'SMS'
      end

      click_on 'Create'

      expect(current_path).to eq(patient_path(1))
      expect(page).to have_content('email@email.com')
      expect(page).to have_content('100001')
      expect(page).to have_content('+6512345678')
      expect(page).to have_content('SMS')
    end
  end

  describe "Viewing patient's info" do
    context 'Has No Patients' do
      it 'should see an emply active list' do
        visit patients_path
        expect(page).to have_content('No patient available')
      end

      it 'should see an empty all list' do
        visit patients_path(filter: 'all')
        expect(page).to have_content('No patient available')
      end
    end

    context 'Has inactive patients' do
      before :each do
        @p1 = create(:patient)
        @p2 = create(:schedule_in_past).patient
        @p3 = create(:schedule_in_future).patient
      end

      it 'should see a list of patient' do
        visit patients_path(filter: 'all')

        expect(page).to have_content(@p1.mist_id)
        expect(page).to have_content(@p2.mist_id)
        expect(page).to have_content(@p3.mist_id)
      end

      it "should see the patient's details" do
        visit patients_path(filter: 'all')
        find('table tbody tr:last-child').click_link('View')

        expect(current_path).to eq(patient_path(@p1))
        expect(page).to have_content(@p1.mist_id)
      end
    end

    context 'Has active patients' do
      before :each do
        @patient = create(:schedule).patient
      end

      it 'should see a list of patient' do
        visit patients_path
        expect(page).to have_content(@patient.mist_id)
      end

      it "should see the patient's details" do
        visit patients_path
        find('table tbody tr:last-child').click_link('View')

        expect(current_path).to eq(patient_path(@patient))
        expect(page).to have_content(@patient.mist_id)
      end
    end
  end

  describe "Editing patient's info" do
    before :each do
      @patient = create(:patient)

      @patient.notification_services << NotificationService.find(1)
      @patient.save

      visit edit_patient_path(@patient)
    end

    it 'should view edit page' do
      expect(page).to have_content('Email')
      expect(page).to have_content('Phone')
      expect(page).to have_content('Notification')

      expect(find('#patient_notification_service_ids_1').checked?).to be_true
      expect(find('#patient_notification_service_ids_2').checked?).to be_false
    end

    it 'should edit the info' do
      within '#edit_patient_#{@patient.id}' do
        uncheck attributes_for(:service_sms)[:name]
        check attributes_for(:service_push)[:name]
      end

      click_on 'Update'

      expect(current_path).to eq(patient_path(1))
      expect(page).to have_content(attributes_for(:service_push)[:name])
    end
  end
end
