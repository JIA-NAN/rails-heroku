# == Schema Information
#
# Table name: schedules
#
#  id            :integer          not null, primary key
#  started_at    :date
#  terminated_at :date
#  patient_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe Schedule do
  context 'is valid' do
    it 'without terminated_at date' do
      schedule = build(:schedule)
      expect(schedule.valid?).to be_true
    end

    it 'without terminated_at date' do
      schedule = build(:schedule,
                       started_at: 1.week.ago,
                       terminated_at: nil)

      expect(schedule.valid?).to be_true
    end
  end

  context 'is not valid' do
    it 'terminated_at before started_at' do
      schedule = build(:schedule,
                       started_at: 1.week.ago,
                       terminated_at: 2.weeks.ago)

      expect(schedule.valid?).to be_false
    end

    it 'terminated_at the same as started_at' do
      schedule = build(:schedule,
                       started_at: 1.week.ago.midnight,
                       terminated_at: 1.week.ago.midnight)

      expect(schedule.valid?).to be_false
    end
  end

  it '#active scope schedule currently in' do
    snow = create(:schedule)
    create(:schedule_in_past)
    create(:schedule_in_future)

    expect(Schedule.active).to eq([snow])
  end

  it '#active scope return nil if nothing in' do
    create(:schedule_in_past)
    create(:schedule_in_future)

    expect(Schedule.active).to eq([])
  end

  context '#nearest_pill_time' do
    before :each do
      @schedule = build(:schedule)
    end

    it 'find nearest with default time' do
      time = Time.zone.now
      target = Ptime.to_time(Ptime.to_ptime(time))

      @schedule.stub(pill_times_from: [Ptime.to_ptime(time)])

      expect(@schedule.nearest_pill_time).to eq(target)
    end

    it 'find nearest from today' do
      @schedule.stub(pill_times_from: [900, 2300])

      time = Time.zone.parse('08:00:59')
      target = Time.zone.parse('09:00:59')
      expect(@schedule.nearest_pill_time(time)).to eq(target)

      time = Time.zone.parse('07:10:59')
      expect(@schedule.nearest_pill_time(time)).to be_nil

      time = Time.zone.parse('12:01:59')
      expect(@schedule.nearest_pill_time(time)).to be_nil
    end

    it 'find nearest from today if yesterday is not in schedule' do
      @schedule.started_at = Time.zone.now
      @schedule.stub(pill_times_from: [900, 2300])

      time = Time.zone.parse('02:00:59')
      expect(@schedule.nearest_pill_time(time)).to be_nil
    end

    it 'find nearest from yesterday' do
      @schedule.stub(pill_times_from: [900, 2300])

      time = Time.zone.parse('02:00:59')
      target = Time.zone.parse('23:00:59') - 1.day
      expect(@schedule.nearest_pill_time(time)).to eq(target)

      time = Time.zone.parse('02:10:59')
      expect(@schedule.nearest_pill_time(time)).to be_nil
    end

    it 'find nearest from today if tomorrow is not in schedule' do
      @schedule.terminated_at = Time.zone.now
      @schedule.stub(pill_times_from: [10, 900])

      time = Time.zone.parse('23:10:59')
      expect(@schedule.nearest_pill_time(time)).to be_nil
    end

    it 'find nearest from tomorrow' do
      @schedule.stub(pill_times_from: [10, 900])

      time = Time.zone.parse('23:10:59')
      target = Time.zone.parse('00:10:59') + 1.day
      expect(@schedule.nearest_pill_time(time)).to eq(target)

      time = Time.zone.parse('23:00:59')
      expect(@schedule.nearest_pill_time(time)).to be_nil
    end
  end

  context '#future_pill_time' do
    before :each do
      @schedule = build(:schedule)
    end

    it 'get pill time today' do
      @schedule.stub(pill_times_from: [900, 1000])
      Ptime.stub(seconds_to_now: 2.hours)

      expect(@schedule.future_pill_time).to eq(time: 900, date: :today)
    end

    it 'get pill time tomorrow' do
      @schedule.stub(pill_times_from: [900, 1000])
      Ptime.stub(seconds_to_now: 30.minutes)

      expect(@schedule.future_pill_time).to eq(time: 900, date: :tomorrow)
    end

    it 'get nil pill time tomorrow' do
      @schedule.stub(pill_times_from: [])

      expect(@schedule.future_pill_time).to eq(time: nil, date: :tomorrow)
    end
  end
end
