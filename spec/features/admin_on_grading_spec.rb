require 'rails_helper'

RSpec.describe 'Admin on Grading Records', :type => :feature do
  before :each do
    @admin = create(:admin, email: 'admin@admin.com')
    admin_login('admin@admin.com', 'adminadmin')
  end

  it 'reads instruction to add pill sequence' do
    visit grading_path
    expect(page).to have_content('Please add a set of step-by-step instructions')
  end

  context 'grade individual records' do
    let(:record) { create(:record) }

    it 'should create grade' do
      visit record_path(record)

      within '#new_grade' do
        fill_in 'Feedback to Patient', with: 'Good'
        fill_in 'Private Note', with: 'Good'
      end
      click_on 'Save Grade'

      expect(page).to have_content('Result: satisfactory')
      expect(page).to have_content('Feedback: Good')
      expect(page).to have_content('Private Note: Good')
    end

    it 'should edit grade' do
      create(:grade, record: record, admin: @admin)

      visit record_path(record)
      expect(page).to have_content('Edit Grading')

      click_on 'Edit Grading'
      expect(current_path).to eq(edit_patient_record_path(record.patient, record))

      within '.edit_grade' do
        select 'unsatisfactory', from: 'Grade'
        fill_in 'Feedback to Patient', with: 'Good'
        fill_in 'Private Note', with: 'Good'
      end
      click_on 'Save Grade'

      expect(page).to have_content('Result: unsatisfactory')
      expect(page).to have_content('Feedback: Good')
      expect(page).to have_content('Private Note: Good')
    end
  end

  context 'Admin can grade records in bulk' do
    before :each do
      @web = create(:PillSequence, name: 'web')
      @ios = create(:PillSequence, name: 'ios')
      # sample records
      @r1 = create(:record, pill_sequence: @web, video_steplized_file_name: 'ab')
      @r2 = create(:record, pill_sequence: @ios, video_steplized_file_name: 'ab')
    end

    it 'should in web sequence' do
      visit grading_path

      expect(page).to have_content('webios')
      expect(first('dd.active')).to have_content('web')
      expect(page).to have_content('From: #{@r1.patient.fullname}')
    end

    it 'should in ios sequence' do
      visit grading_path(id: 2)

      expect(page).to have_content('webios')
      expect(first('dd.active')).to have_content('ios')
      expect(page).to have_content('From: #{@r2.patient.fullname}')
    end
  end
end
