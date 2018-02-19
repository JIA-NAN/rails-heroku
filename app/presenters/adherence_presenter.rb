class AdherencePresenter
  ADHERENCE_TYPES = ['Yes', 'No', 'Partial', 'Pending', 'N/A'].freeze
  ADHERE_YES, ADHERE_NO, ADHERE_PARTIAL, ADHERE_PENDING, ADHERE_NA = ADHERENCE_TYPES

  def initialize(patient)
    @patient = patient
  end

  def date_within_schedule?(date)
    @patient.schedules.each do |schedule|
      if date >= schedule.started_at && date <= schedule.terminated_at && date < Date.today
        return true
      end
    end
    return false
  end

  def get_adherence_status_on(date)
    records = get_records(date)
    if records.empty?
      if date_within_schedule?(date)
        return ADHERE_NO
      else
        return ADHERE_NA
      end
    end

    adhere_count = 0
    records.each do |r|
      if r.graded
        if r.grade.pill_taken == Grade::PILL_TAKEN
          adhere_count += 1
        elsif r.grade.pill_taken == Grade::NOT_SURE_IF_PILL_TAKEN
          return ADHERE_PENDING
        end
      else
        return ADHERE_PENDING
      end
    end
    if adhere_count == records.length
      return ADHERE_YES
    elsif adhere_count.zero?
      return ADHERE_NO
    else
      return ADHERE_PARTIAL
    end
  end

  def get_records(date)
    return Record.where(patient_id: @patient).from_date(date)
  end
end
