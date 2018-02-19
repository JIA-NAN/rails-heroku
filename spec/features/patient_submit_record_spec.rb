require 'rails_helper'

RSpec.describe 'Patient on Submitting Records', :type => :feature do
  before :each do
    @patient = create(:patient)
    patient_login('100001', '12345678')
  end

  context 'no schedule allocated' do
    it 'reads has no schedule message' do
      visit root_path
      expect(page).to have_content('You do not have any schedule.')
    end
  end

  context 'has a schedule' do
    before :each do
      @schedule = create :schedule, patient: @patient
      @pill_time = create :pill_time,
                          schedule => @schedule,
                          Ptime.weekday_today => Ptime.to_ptime(Time.zone.now + 4.hours)
    end

    it 'reads next pill time' do
      visit root_path
      expect(page).to have_content(/Your next pill is at \d?\d:\d\d/i)
      expect(page).to have_content('No record submitted today')
    end

    it 'reads records list' do
      create(:record, patient: @patient)

      visit root_path
      expect(page).to have_content(/Your next pill is at \d?\d:\d\d/i)
      expect(page).to have_content("Today's record History")
    end
  end
end
