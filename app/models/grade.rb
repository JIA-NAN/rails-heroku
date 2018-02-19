# == Schema Information
#
# Table name: grades
#
#  id         :integer          not null, primary key
#  grade      :string(255)
#  pill_taken :string(64)       'yes', 'no', 'unknown'
#  explanation :string(64)       'tech', 'others', 'unknown'
#  comment    :text
#  record_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  admin_id   :integer
#  note       :text
#

# The Grade model encapsutlates the result of grading performed on a
# patient's record.
class Grade < ActiveRecord::Base
  # GRADE_TYPES = ["satisfactory", "unsatisfactory", "pending", "nonadherence", "excused"]
  PILL_TAKEN_TYPES = ['Yes', 'No', 'Not Sure'].freeze
  PILL_TAKEN, PILL_NOT_TAKEN, NOT_SURE_IF_PILL_TAKEN = PILL_TAKEN_TYPES
  # SATISFY, UNSATISFY, PENDING, NONADHERENCE, EXCUSED = GRADE_TYPES

  EXPLANATION_TYPES = ['Technical Issue', 'Others', 'Unknown'].freeze
  EXPLANATION_TECHNICAL_ISSUE, EXPLANATION_OTHERS, EXPLANATION_UNKNOWN = EXPLANATION_TYPES

  attr_accessible :note, :comment, :grade, :record, :record_id, :admin_id, :pill_taken, :explanation

  # validates :grade, presence: true, inclusion: { in: GRADE_TYPES }

  belongs_to :admin
  belongs_to :record

  default_scope -> { order('grades.created_at DESC') }
  scope :this_week, -> { where('grades.created_at > ?', 1.week.ago.in_time_zone) }
  scope :with_comment, -> { where("grades.comment != '' AND grades.comment IS NOT NULL") }

  after_save :upgrade_record_status, if: :pill_taken_changed?
  def upgrade_record_status
    Rails.logger.debug 'pill taken changed'
    record.set_graded
    if pill_taken == 'Yes'
      record.patient.update_wallet
    end
  end

  after_destroy :ungrade_record_status
  def ungrade_record_status
    record.ungraded
  end
end
