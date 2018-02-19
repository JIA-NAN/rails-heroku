require 'rails_helper'

RSpec.describe 'Admin on Records', :type => :feature do
  before :each do
    @admin = create(:admin, email: 'admin@admin.com')
    admin_login('admin@admin.com', 'adminadmin')
  end

  it 'should on dashboard and see no records' do
    expect(current_path).to eq(dashboard_path)
    expect(page).to have_content('No new records')
  end

  context 'has new records' do
    before :each do
      # 2 patients
      @patient_1 = create(:patient, firstname: 'patient_1')
      @patient_2 = create(:patient, firstname: 'patient_2')
      # 2 pending records
      @pending_1 = create(:record, patient: @patient_1)
      @pending_2 = create(:record, patient: @patient_2)
      # 2 missing records
      @missing_1 = create(:record,  patient: @patient_1, status: Record::MISSING)
      @missing_2 = create(:record,  patient: @patient_2, status: Record::MISSING)
      # 1 graded record
      @graded = create(:grade_with_record).record
    end

    it 'should see new records on dashboard' do
      visit dashboard_path

      expect(find('.dashboard-pending-records')).to have_content(@patient_1.fullname)
      expect(find('.dashboard-pending-records')).to have_content(@patient_2.fullname)
      expect(find('.dashboard-missing-records')).to have_content(@patient_1.fullname)
      expect(find('.dashboard-missing-records')).to have_content(@patient_2.fullname)
    end

    it 'should see all records on record page' do
      visit records_path
      expect(find('dd.active')).to have_content('All')

      expect(page).to have_content('graded (Y)')
      expect(page).to have_content('pending')
      expect(page).to have_content('missing')
    end

    context 'filters' do
      it 'should see pending records on Pending filter' do
        visit records_path(filter: 'pending')

        expect(find('dd.active')).to have_content('Pending')
        expect(page).to have_selector('#record_1')
        expect(page).to have_selector('#record_2')
        expect(page).to have_content(@patient_1.fullname)
        expect(page).to have_content(@patient_2.fullname)
      end

      it 'should see missing records on Missing filter' do
        visit records_path(filter: 'missing')

        expect(find('dd.active')).to have_content('Missing')
        expect(page).to have_selector('#record_3')
        expect(page).to have_selector('#record_4')
        expect(page).to have_content(@patient_1.fullname)
        expect(page).to have_content(@patient_2.fullname)
      end

      it 'should see graded records on Graded filter' do
        visit records_path(filter: 'graded')

        expect(find('dd.active')).to have_content('Graded')
        expect(page).to have_selector('#record_5')
      end
    end
  end
end
