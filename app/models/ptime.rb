class Ptime

  # Public: Get today's weekday
  #
  # Return "monday", "tuesday" .. "sunday"
  def self.weekday_today
    Time.zone.now.strftime('%A').downcase
  end

  # Public: Get yesterday's weekday
  #
  # Return "monday", "tuesday" .. "sunday"
  def self.weekday_yesterday
    Time.zone.now.yesterday.strftime('%A').downcase
  end

  # Public: Get tomorrow's weekday
  #
  # Return "monday", "tuesday" .. "sunday"
  def self.weekday_tomorrow
    Time.zone.now.tomorrow.strftime('%A').downcase
  end

  # Public: Get a date's weekday
  #
  # date - a Date Time
  #
  # Return "monday", "tuesday" .. "sunday"
  def self.weekday_of(date)
    date.in_time_zone.strftime('%A').downcase
  end

  # Public: get time now in pill time format
  #
  # Return time in pill_time format
  def self.now
    to_ptime(Time.zone.now)
  end

  # Public: convert datetime to pill time format
  #
  # time - datetime
  #
  # Returns pill time format
  def self.to_ptime(time)
    time && time.strftime('%H%M').to_i
  end

  # Public: Convert a pill time format to time
  #
  # time - a pill time, e.g: 1010
  # base_date - a base DateTime, default: Time.zone.now
  #
  # Examples
  #
  # 1010 => base_date 10:10:59 am
  # 1310 => base_date 01:10:59 pm
  #
  # Returns a DateTime that represents the pill time in base_date
  def self.to_time(time, base_date = nil)
    return nil unless time

    hour = time / 100
    mins = time % 100

    base_date = word_to_time(base_date || Time.zone.now)
    base_date.change hour: hour, min: mins, sec: 59
  end

  # Public: Convert a symbol to time
  #
  # time - :today, :tomorrow, :yesterday
  #
  # Returns a DateTime
  def self.word_to_time(time)
    case time
    when :today
      Time.zone.now
    when :tomorrow
      Time.zone.now.tomorrow
    when :yesterday
      Time.zone.now.yesterday
    else
      time
    end
  end

  # Public: Get the seconds from a pill time to now
  #
  # from_time - in pill time format
  #
  # Examples
  #
  # given now = today 10:10:59 am
  #
  # Ptime.seconds_to_now(1000) => -600
  # Ptime.seconds_to_now(1020) =>  600
  #
  # Return in seconds
  def self.seconds_to_now(time)
    seconds_between(time, Time.zone.now)
  end

  # Public: Get the seconds from now to a pill time
  #
  # to_time - in pill time format
  #
  # Examples
  #
  # given now = today 10:10:59 am
  #
  # Ptime.seconds_from(1000) =>  600
  # Ptime.seconds_from(1020) => -600
  #
  # Return in seconds
  def self.seconds_from(time)
    seconds_between(Time.zone.now, time)
  end

  # Public: Get the seconds from a pill time to another time
  #
  # a - in Time, or pill time format
  # b - in Time, or pill time format
  #
  # Examples
  #
  # Ptime.seconds_between(1000, 1010) => -600
  # Ptime.seconds_between(1000, Time.zone.now) => -600
  # Ptime.seconds_between(1020, 1010) =>  600
  # Ptime.seconds_between(1020, Time.zone.now) =>  600
  #
  # Return in seconds
  def self.seconds_between(a, b)
    a = a.is_a?(Fixnum) ? to_time(a) : a
    b = b.is_a?(Fixnum) ? to_time(b) : b

    (a - b).to_i
  end

  # Public: Convert the time from normal time to pill_time format
  #
  # time - integer for minute, float for hours
  # unit - time unit :minute, or :hour (default: :minute)
  #
  # Examples
  #
  #   30 mins =>   30
  #  -90 mins => -130
  #    1 hr   =>  100
  # -1.2 hrs  => -115
  #
  # Return time in pill_time format
  def self.convert(time, unit = :minute)
    abs_convert(time, unit) * (time >= 0 ? 1 : -1)
  end

  # Public: Convert a normal time to pill_time format (in positive)
  #
  # time - integer for minute, float for hours
  # unit - time unit :minute, or :hour (default: :minute)
  #
  # Examples
  #
  #   30 mins =>  30
  #  -90 mins => 130
  #    1 hr   => 100
  # -1.2 hrs  => 115
  #
  # Return time in pill_time format
  def self.abs_convert(time, unit = :minute)
    time = time.abs

    if unit == :minute
      return (time / 60 * 100) + (time % 60)
    elsif unit == :hour
      hour = (time * 10 / 10).to_i
      mins = (time - hour) * 60

      return ((hour * 100) + mins).to_i
    end
  end

  # Public: convert time to readable
  #
  # time - a pill time
  # format - :ampm, or :short (24 hours format)
  #
  # Examples
  #
  # to_human_readable(800)  =>  8:00 am
  # to_human_readable(1000) => 10:00 am
  # to_human_readable(2310) => 11:10 pm
  #
  # to_human_readable(800,  :short) =>  8:00
  # to_human_readable(2310, :short) => 23:10
  #
  # Returns string
  def self.to_human_readable(time, format = :ampm)
    return nil if time.nil?
    return time.in_time_zone.strftime('%F %H:%M') if time.is_a? Time

    hour = time / 100
    mins = time % 100
    mins = '0' + mins.to_s if mins <= 9

    if format == :ampm
      unit = hour < 12 ? 'am' : 'pm'
      hour = (hour - 12).to_s if hour > 12

      "#{hour}:#{mins} #{unit}"
    else
      "#{hour}:#{mins}"
    end
  end

  # Internal: convert seconds to time distance string
  #
  # sec = seconds
  #
  # Examples
  #
  # to_human_readable(60) => 1 minute
  # to_human_readable(3600) => 1 hour
  #
  # Return string
  def self.to_time_distance(sec)
    sec  = sec.abs
    hour = sec / 3600
    min  = sec / 60 - hour * 60

    if hour > 1
      if min == 0
        "#{hour} hours"
      elsif min == 30
        "#{hour} and a half hours"
      else
        "#{hour} hours and #{min} minutes"
      end
    elsif hour == 1
      "#{60 + min} minutes"
    elsif min > 1
      "#{min} minutes"
    else
      "1 minute"
    end
  end

end
