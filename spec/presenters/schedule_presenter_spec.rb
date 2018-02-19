require 'spec_helper'

describe SchedulePresenter do
  before :each do
    @schedule = create(:schedule)
    create(:pill_time, schedule: @schedule)

    @patient = @schedule.patient
    create_list(:record, 2, patient: @patient)
    create_list(:record, 3, patient: @patient, status: Record::MISSING)
    create(:record, patient: @patient, pill_time_at: Time.zone.now - 1.month)
    create(:record, patient: @patient, pill_time_at: Time.zone.now + 1.month)
  end

  it 'should count submitted' do
    presenter = SchedulePresenter.new(@schedule)
    expect(presenter.submitted).to eq(5)
  end

  it 'should count expected' do
    presenter = SchedulePresenter.new(@schedule)
    expect(presenter.expected).to eq(8)
  end

  it 'should count different status' do
    presenter = SchedulePresenter.new(@schedule)

    expect(presenter.pending).to eq(2)
    expect(presenter.missing).to eq(3)

    Record::STATUS_TYPES.each do |status|
      unless [Record::PENDING, Record::MISSING].include? status
        expect(presenter.send(status)).to eq(0)
      end
    end
  end

  it 'should count different status with grade' do
    presenter = SchedulePresenter.new(@schedule)

    [Record::GRADED, Record::EXCUSED].each do |status|
      [Grade::SATISFY, Grade::UNSATISFY].each do
        expect(presenter.send(status)).to eq(0)
      end
    end
  end
end
