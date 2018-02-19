require 'rails_helper'

RSpec.describe 'Patient on Excuses', :type => :feature do
  before :each do
    @patient = create(:patient)
    create_list(:record, 2, patient: @patient, comment: nil, status: Record::MISSING)

    patient_login('100001', '12345678')
  end

  it 'should see missing records' do
    visit records_path(filter: 'missing')
    expect(page).to have_selector('#record_1, #record_2')
  end

  it "should see a missing record's detail" do
    visit patient_record_path(@patient, 1)
    expect(page).to have_content(/Record Status:\s*missing/)
    expect(page).to have_content('Submit Explanation')
  end

  it 'should be able to leave an explanation' do
    visit patient_record_path(@patient, 1)

    fill_in 'record_comment', with: 'blablabla'
    click_on 'Submit'

    expect(page).to have_content('Record was successfully updated.')
    expect(page).to have_content(/Explanation:\s*blablabla/)
  end

  it "should see an excuse's grade" do
    excuse = create(:record, patient: @patient, status: Record::MISSING)
    create(:grade_with_record, record: excuse)

    visit patient_record_path(@patient, excuse)
    expect(page).to have_content(/Result:\s*satisfactory/)
    expect(page).to have_content(/Feedback:\s*comment/)
  end
end
