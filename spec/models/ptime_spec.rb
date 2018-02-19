require 'spec_helper'

describe Ptime do
  it '#weekday_of any date' do
    expect(Ptime.weekday_of(Time.zone.now)).to eq(Ptime.weekday_today)
    expect(Ptime.weekday_of(Time.zone.now - 1.day)).to eq(Ptime.weekday_yesterday)
    expect(Ptime.weekday_of(Time.zone.now + 1.day)).to eq(Ptime.weekday_tomorrow)
  end

  context '#to_time' do
    it 'converts Ptime to DateTime' do
      base = Time.zone.now

      expect(Ptime.to_time(nil)).to be_nil
      expect(Ptime.to_time(0)).to eq(
        base.change(hour: 0, min: 0, sec: 59)
      )
      expect(Ptime.to_time(10)).to eq(
        base.change(hour: 0, min: 10, sec: 59)
      )
      expect(Ptime.to_time(110)).to eq(
        base.change(hour: 1, min: 10, sec: 59)
      )
      expect(Ptime.to_time(1000)).to eq(
        base.change(hour: 10, min: 0, sec: 59)
      )
      expect(Ptime.to_time(1059)).to eq(
        base.change(hour: 10, min: 59, sec: 59)
      )
      expect(Ptime.to_time(1349)).to eq(
        base.change(hour: 13, min: 49, sec: 59)
      )
      expect(Ptime.to_time(2359)).to eq(
        base.change(hour: 23, min: 59, sec: 59)
      )
    end

    it 'can converts based on a base time' do
      time = Time.zone.now.yesterday
      base = Time.zone.now.yesterday

      expect(Ptime.to_time(nil)).to be_nil
      expect(Ptime.to_time(0, time)).to eq(
        base.change(hour: 0, min: 0, sec: 59)
      )
      expect(Ptime.to_time(10, time)).to eq(
        base.change(hour: 0, min: 10, sec: 59)
      )
      expect(Ptime.to_time(110, time)).to eq(
        base.change(hour: 1, min: 10, sec: 59)
      )
      expect(Ptime.to_time(1000, time)).to eq(
        base.change(hour: 10, min: 0, sec: 59)
      )
      expect(Ptime.to_time(1059, time)).to eq(
        base.change(hour: 10, min: 59, sec: 59)
      )
      expect(Ptime.to_time(1349, time)).to eq(
        base.change(hour: 13, min: 49, sec: 59)
      )
      expect(Ptime.to_time(2359, time)).to eq(
        base.change(hour: 23, min: 59, sec: 59)
      )
    end
  end

  it 'get #seconds_between to_time - from_time' do
    expect(Ptime.seconds_between(1000, 1001)).to eq(-60)
    expect(Ptime.seconds_between(1001, 1000)).to eq(60)
    expect(Ptime.seconds_between(1001, 1001)).to eq(0)
  end

  it 'get #seconds_to_now' do
    fake_now = Time.zone.now.change hour: 10, min: 10, sec: 59
    Time.zone.stub(now: fake_now)

    expect(Ptime.seconds_to_now(1000)).to eq(-600)
    expect(Ptime.seconds_to_now(1020)).to eq(600)
  end

  it 'get #seconds_from' do
    fake_now = Time.zone.now.change hour: 10, min: 10, sec: 59
    Time.zone.stub(now: fake_now)

    expect(Ptime.seconds_from(1000)).to eq(600)
    expect(Ptime.seconds_from(1020)).to eq(-600)
  end

  it '#convert unit time to Ptime' do
    # minute
    expect(Ptime.convert(0)).to eq(0)
    expect(Ptime.convert(1)).to eq(1)
    expect(Ptime.convert(60)).to eq(100)
    expect(Ptime.convert(90)).to eq(130)

    # minute explicit
    expect(Ptime.convert(0, :minute)).to eq(0)
    expect(Ptime.convert(1, :minute)).to eq(1)
    expect(Ptime.convert(60, :minute)).to eq(100)
    expect(Ptime.convert(90, :minute)).to eq(130)

    # hour
    expect(Ptime.convert(0, :hour)).to eq(0)
    expect(Ptime.convert(1, :hour)).to eq(100)
    expect(Ptime.convert(1.0, :hour)).to eq(100)
    expect(Ptime.convert(1.5, :hour)).to eq(130)
  end

  it '#to_human_readable' do
    # ampm
    expect(Ptime.to_human_readable(0)).to eq('0:00 am')
    expect(Ptime.to_human_readable(9)).to eq('0:09 am')
    expect(Ptime.to_human_readable(159)).to eq('1:59 am')
    expect(Ptime.to_human_readable(1059)).to eq('10:59 am')
    expect(Ptime.to_human_readable(1409)).to eq('2:09 pm')
    expect(Ptime.to_human_readable(2339)).to eq('11:39 pm')

    # 24 hrs
    expect(Ptime.to_human_readable(0, :short)).to eq('0:00')
    expect(Ptime.to_human_readable(9, :short)).to eq('0:09')
    expect(Ptime.to_human_readable(159, :short)).to eq('1:59')
    expect(Ptime.to_human_readable(1059, :short)).to eq('10:59')
    expect(Ptime.to_human_readable(1409, :short)).to eq('14:09')
    expect(Ptime.to_human_readable(2339, :short)).to eq('23:39')
  end

  it '#to_time_distance' do
    expect(Ptime.to_time_distance(0.minutes)).to eq('1 minute')
    expect(Ptime.to_time_distance(1.minute)).to eq('1 minute')
    expect(Ptime.to_time_distance(2.minutes)).to eq('2 minutes')
    expect(Ptime.to_time_distance(60.minutes)).to eq('60 minutes')
    expect(Ptime.to_time_distance(70.minutes)).to eq('70 minutes')
    expect(Ptime.to_time_distance(2.hours)).to eq('2 hours')
    expect(Ptime.to_time_distance(2.hours + 10.minutes)).to eq('2 hours and 10 minutes')
    expect(Ptime.to_time_distance(2.hours + 30.minutes)).to eq('2 and a half hours')
    expect(Ptime.to_time_distance(3.hours)).to eq('3 hours')
    expect(Ptime.to_time_distance(3.hours + 30.minutes)).to eq('3 and a half hours')
    expect(Ptime.to_time_distance(3.hours + 45.minutes)).to eq('3 hours and 45 minutes')
  end
end
