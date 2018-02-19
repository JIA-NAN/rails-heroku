module RecordsHelper
  RECORD_CATEGORY = ['Pill Taken', 'Pill Not Taken', 'Not Sure',
                     'Pending (Missing)', 'Pending (Received)'].freeze
  PILL_TAKEN, PILL_NOT_TAKEN, NOT_SURE_IF_PILL_TAKEN,
    PENDING_MISSING, PENDING_RECEIVED = RECORD_CATEGORY

  def display_filters
    return "<a href='?received=yes'>Submitted</a>
      <a href='?received=no'>Missing</a>
      <a href='?received=yes&graded=yes'>TODO</a>
      <a href='?received=yes&grade=unsatisfactory'>TODO</a>
      <a href='?received=no&grade=excused'>TODO</a>
      <a href='?received=no&grade=nonadherence'>TODO</a>"
  end

  def display_grade(record)
    if !record.grade.nil?
      if record.grade.pill_taken == Grade::PILL_TAKEN
        return RecordsHelper::PILL_TAKEN
      end
      if record.grade.pill_taken == Grade::PILL_NOT_TAKEN
        return RecordsHelper::PILL_NOT_TAKEN
      end
      if record.grade.pill_taken == Grade::NOT_SURE_IF_PILL_TAKEN
        return RecordsHelper::NOT_SURE_IF_PILL_TAKEN
      end
    end
    if record.received == false
      return RecordsHelper::PENDING_MISSING
    end
    if record.received == true
      return RecordsHelper::PENDING_RECEIVED
    end
  end

  def record_status(record)
    # This is for communication between ruby and js
    if !record.grade.nil?
      if record.grade.pill_taken == Grade::PILL_TAKEN
        return 'yes'
      end
      if record.grade.pill_taken == Grade::PILL_NOT_TAKEN
        return 'no'
      end
      if record.grade.pill_taken == Grade::NOT_SURE_IF_PILL_TAKEN
        return 'maybe'
      end
    end
    if record.received == false
      return 'missing'
    end
    if record.received == true
      return 'pending'
    end
  end

  def display_explanation(record)
	  if record.grade != nil
		  return record.grade.explanation
	  else
		  return "Pending"
	  end
  end

  def display_self_report(record)
    if record.report == 0
      return 'Missed Medication'
    elsif record.report == 1
      return 'Medication Taken'
    else
      return 'N/A'
    end
  end

  # display record submission diff
  def pill_taking_time_diff(record)
    ptime = record.pill_time_at
    ctime = record.actual_pill_time_at
	if ctime == nil
		return "No submission"
	end
    range = (ptime - 10.minutes)..(ptime + 10.minutes)

    if range.cover? ctime
      "Taken on time"
    elsif record.created_at < record.pill_time_at
      "Taken early by #{distance_of_time_in_words(ctime, ptime)}"
    else
      "Taken late by #{distance_of_time_in_words(ctime, ptime)}"
    end
  end

  # display record submission diff
  def submission_time_diff(record)
    ptime = record.pill_time_at
    ctime = record.created_at
    range = (ptime - 10.minutes)..(ptime + 10.minutes)

    if range.cover? ctime
      "Submitted on time"
    elsif record.created_at < record.pill_time_at
      "Submitted early by #{distance_of_time_in_words(ctime, ptime)}"
    else
      "Submitted late by #{distance_of_time_in_words(ctime, ptime)}"
    end
  end

  def display_comment_name(record)
    if record.is_excuse?
      "Explanation"
    else
      "Comment"
    end
  end

  # patient has explained
  def has_an_explanation?(record)
    record.is_excuse? && record.comment && !record.comment.empty?
  end

  # generate video download filename
  def video_download_filename(record)
    name = record.patient.fullname(:dashed)[0..50]
    time = record.created_at.to_s(:number)

    if record.video_file_name

      ext = record.video_file_name[/\.([^\.]+)$/]

    else

      ext = record.video_s3_file_name[/\.([^\.]+)$/]

    end

    "#{name}_#{time}#{ext}"
  end
end
