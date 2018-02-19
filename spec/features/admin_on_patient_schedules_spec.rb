require 'rails_helper'

RSpec.describe "Admin on Patients' Schedules", :type => :feature do
  before :each do
    @admin = create(:admin, email: 'admin@admin.com')
    @patient = create(:patient)

    admin_login('admin@admin.com', 'adminadmin')
    visit patient_path(@patient)
  end

  it 'should see no schedule' do
    expect(page).to have_content('No Schedule Available')
  end

  it 'should create new schedule' do
    click_link 'New Schedule'
    expect(current_path).to eq(new_patient_schedule_path(@patient))

    click_on 'Save Schedule'
    expect(current_path).to match(%r{/patients\/\d+\/schedules\/\d+/})
  end

  it 'should edit new schedule' do
    schedule = create(:schedule, patient: @patient)
    create(:pill_time, schedule: schedule)

    visit patient_path(@patient)
    expect(page).not_to have_content('No Schedule Available')

    find('.patient-schedule').click_on('Edit')
    expect(current_path).to eq(edit_patient_schedule_path(@patient, schedule))

    click_on 'Save Schedule'
    expect(current_path).to eq(patient_schedule_path(@patient, schedule))
  end

  context '#show' do
    before :each do
      @schedule = create(:schedule, patient: @patient)
      @pill_times = create(:pill_time, schedule: @schedule)
    end

    it 'should read schedule summary' do
      visit patient_schedule_path(@patient, @schedule)

      expect(page).to have_content('Pending 0')
      expect(page).to have_content('Graded 0')
      expect(page).to have_content('Missing 0')
      expect(page).to have_content('Excused 0')
      expect(page).to have_content('Submitted 0')
      expect(page).to have_content('Expected 8')
    end

    it 'should read grading summary' do
      visit patient_schedule_path(@patient, @schedule)

      expect(page).to have_content('Satisfactory 0')
      expect(page).to have_content('Unsatisfactory 0')
      expect(page).to have_content('Approved 0')
      expect(page).to have_content('Rejected 0')
    end
  end
end
