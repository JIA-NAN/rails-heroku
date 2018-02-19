require 'rails_helper'

RSpec.describe 'Patient on Records', :type => :feature do
  before :each do
    @patient = create(:patient)
    patient_login('100001', '12345678')
  end

  context 'has no records' do
    it 'should see an empty record list' do
      visit records_path
      expect(page).to have_content('No records available.')
    end
  end

  context 'has many records' do
    before :each do
      create_list(:record, 2, patient: @patient)
      create_list(:record, 2, patient: @patient, status: Record::MISSING)
    end

    it 'should see submitted records in page' do
      visit records_path

      expect(page).to have_selector('#record_1')
      expect(page).to have_selector('#record_2')
      expect(page).to have_selector('#record_3')
      expect(page).to have_selector('#record_4')
    end

    context 'filters' do
      it 'should see all records on All filter' do
        visit records_path

        expect(page).to have_content('Filter:AllPendingGradedOnhold')
        expect(find('dd.active')).to have_content('All')
      end

      it 'should see pending records on Pending filter' do
        visit records_path(filter: 'pending')

        expect(find('dd.active')).to have_content('Pending')
        expect(page).to have_selector('#record_1')
        expect(page).to have_selector('#record_2')
        expect(page).not_to have_selector('#record_3')
        expect(page).not_to have_selector('#record_4')
      end

      it 'should see missing records on Missing filter' do
        visit records_path(filter: 'missing')

        expect(find('dd.active')).to have_content('Missing')
        expect(page).to have_selector('#record_3')
        expect(page).to have_selector('#record_4')
        expect(page).not_to have_selector('#record_1')
        expect(page).not_to have_selector('#record_2')
      end

      it 'should see all records on invalid filter' do
        visit records_path(filter: 'does not exists')
        expect(find('dd.active')).to have_content('All')
        expect(page).to have_selector('#record_1, #record_2')
        expect(page).to have_selector('#record_3, #record_4')
      end
    end

    it "should see a record's detail" do
      visit patient_record_path(@patient, 1)
      expect(page).to have_content(/Record Status:\s*pending/)
      expect(page).to have_content(/Comment:\s*comment/)
      expect(page).to have_content('No video')
      expect(page).to have_content('Not Graded')
    end

    it "should see a record's grade" do
      record = create(:record, patient: @patient)
      create(:grade_with_record, record: record)

      visit patient_record_path(@patient, record)
      expect(page).to have_content(/Result:\s*satisfactory/)
      expect(page).to have_content(/Feedback:\s*comment/)
    end
  end
end
