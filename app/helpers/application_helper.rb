module ApplicationHelper

  # determine a patient or an admin signed in
  def any_signed_in?
    admin_signed_in? || patient_signed_in? || false
  end

  # get number of missing record count
  def missing_count
    @missing_count ||= current_patient.records.status(Record::MISSING).count
  end

  # convert time to local time in zone
  def localtime(date, options = {})
    return "" if date.nil?

    if options[:short_form]
        date.in_time_zone.strftime('%F')
    else
      date.in_time_zone.strftime('%F %H:%M')
    end
  end

  # convert to datetime
  def localdatetime(date, options = {})
    return "" if date.nil?

    if options[:datetime]
      date.in_time_zone.strftime('%Y-%m-%dT%T.%L%z')
    else # datetime-local
      date.in_time_zone.strftime('%Y-%m-%dT%T')
    end
  end

  # display an array
  def array(arr, key, empty = 'Nil')
    if arr.empty?
      empty
    elsif key.nil?
      arr.join(', ')
    else
      arr.map { |a| a[key] }.join(', ')
    end
  end

  # display pill time array
  def pill_time(schedule, day)
    if schedule.nil?
      'No Schedule and Pill Time'
    elsif schedule.pill_times.empty?
      'No Pill Time'
    else
      schedule.pill_times.map { |t| format_pill_time t[day] }.join ', '
    end
  end

  def format_pill_time(time)
    Ptime.to_human_readable(time) || 'Completed'
  end

  # display an subnavs
  def display_subnav(name, list, active)
    result = ["<dl class='sub-nav'><dt>#{name}:</dt>"]

    list.each do |item|
      klass = 'active' if item == active
      result << "<dd class='#{klass}'>#{yield item}</dd>"
    end

    result << '</dl>'

    result.join.html_safe
  end

end
