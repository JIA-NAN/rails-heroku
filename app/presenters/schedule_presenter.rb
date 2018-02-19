class SchedulePresenter

  attr_accessor :schedule, :started_at, :terminated_at, :patient

  def initialize(schedule)
    @schedule = schedule
    @patient = @schedule.patient
    @started_at = @schedule.started_at
    @terminated_at = if @schedule.terminated_at && !@schedule.terminated_at.future?
                    @schedule.terminated_at
                  else
                    Time.zone.now.tomorrow.to_date
                  end
  end

  # Public: get the number of records submitted
  def submitted
    records.where(received: true).count
  end

  # Public: get the number of records expected
  def expected
    (@terminated_at - @started_at).to_i * @schedule.pill_times.size
  end

  def received_pending
    records.where(received: true, graded: false).count
  end

  def graded
    records.where(graded: true).count
  end

  def received
    records.where(received: true).count
  end

  def missing
    records.where(received: false).count
  end

  def missing_pending
    records.where(received: false, graded: false).count
  end

  def graded_satisfactory
    records.includes(:grade).where(graded: true, received: true, grades: {pill_taken: 'Yes'}).count
  end

  def graded_unsatisfactory
    records.includes(:grade).where(graded: true, received: true, grades: {pill_taken: 'No'}).count
  end
  def graded_notsure
    records.includes(:grade).where(graded: true, received: true, grades: {pill_taken: 'Not Sure'}).count
  end

  def excused_tech_issue
    records.includes(:grade).where(graded: true, received: false, grades: {explanation: 'Technical Issue'}).count
  end

  def excused_others
    records.includes(:grade).where(graded: true, received: false, grades: {explanation: 'Others'}).count
  end
  def excused_unknown
    records.includes(:grade).where(graded: true, received: false, grades: {explanation: 'Unknown'}).count
  end

  # Public: get the number of records in different status expected
  #Record::STATUS_TYPES.each do |status|
  #  define_method(status) do
  #    records.status(status).count
  #  end
  #end

  # Public: get the number of records with satisfactory/unsatisfactory
  #[Record::GRADED, Record::MISSING].each do |status|
  #  [Grade::SATISFY, Grade::UNSATISFY, Grade::NONADHERENCE, Grade::EXCUSED].each do |grade|
  #    define_method("#{status}_#{grade}") do
  #      records.status(status)
  #             .joins(:grade).where("grades.grade = ?", grade)
  #             .count
  #    end
  #  end
  #end

  private

  def records
    @patient.records.from_period(@started_at, @terminated_at)
  end

end
