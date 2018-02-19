require 'rails_helper'

RSpec.describe 'Patient Login/Account System', :type => :feature do
  before :each do
    @patient = create(:patient)
  end

  describe 'Logging In' do
    it 'should get redirected to patient login page' do
      visit root_path
      expect(current_path).to eq(new_patient_session_path)
    end

    it 'should logged in after enters correct id and password' do
      patient_login('100001', '12345678')
      expect(current_path).to eq(root_path)
      expect(page).to have_content('Signed in successfully.')
    end

    it 'cannot log in if enters wrong id' do
      patient_login('10001', '12345678')
      expect(current_path).to eq(new_patient_session_path)
      expect(page).to have_content('Wrong email or password.')
    end

    it 'cannot log in if enters wrong password' do
      patient_login('100001', '123456789')
      expect(current_path).to eq(new_patient_session_path)
      expect(page).to have_content('Wrong email or password.')
    end
  end

  describe 'Logging Out' do
    before :each do
      patient_login('100001', '12345678')
    end

    it 'should logged out system' do
      click_on 'Logout'
      expect(current_path).to eq(new_patient_session_path)
      expect(page).to have_content('Sign in as User')
    end
  end

  describe 'Account Page' do
    before :each do
      patient_login('100001', '12345678')
    end

    it 'should view account' do
      click_on 'Manage Account'
      expect(current_path).to eq(edit_patient_registration_path)
    end

    it 'should be able to edit account' do
      visit edit_patient_registration_path

      fill_in 'Phone', with: '+6587654321'
      fill_in 'Current password', with: '12345678'
      click_on 'Update'

      expect(current_path).to eq(root_path)
    end
  end
end
