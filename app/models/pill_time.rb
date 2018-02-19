# == Schema Information
#
# Table name: pill_times
#
#  id          :integer          not null, primary key
#  monday      :integer
#  tuesday     :integer
#  wednesday   :integer
#  thursday    :integer
#  friday      :integer
#  saturday    :integer
#  sunday      :integer
#  schedule_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PillTime < ActiveRecord::Base
  attr_accessible :monday, :tuesday, :wednesday, :thursday,
                  :friday, :saturday, :sunday, :medicine_ids, :schedule_id

  # validations
  validates :monday, :tuesday, :wednesday, :thursday,
            :friday, :saturday, :sunday, presence: true

  # relationships
  belongs_to :schedule, touch: true
  has_and_belongs_to_many :medicines

  # get yesterday's pill time slot
  def yesterday
    self[Ptime.weekday_yesterday]
  end

  # get today's pill time slot
  def today
    self[Ptime.weekday_today]
  end

  # get tomorrow's pill time slot
  def tomorrow
    self[Ptime.weekday_tomorrow]
  end
end
