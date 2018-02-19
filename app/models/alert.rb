class Alert < ActiveRecord::Base
  attr_accessible :text,
                  :time_repeat,
                  :time_start,
                  :minute_before_pill_time,
                  :message_before_pill_time,
                  :message_on_pill_time,
                  :message_after_pill_time,
                  :message_full_adherence,
                  :minute_after_pill_time,
                  :day_full_adherence,
                  :day_full_adherence2,
                  :number_time_missing_pill
  validates :minute_after_pill_time, presence: true
  validates :minute_before_pill_time, presence: true
  validates :message_before_pill_time, presence: true
  validates :message_on_pill_time, presence: true
  validates :message_after_pill_time, presence: true
  validates :message_full_adherence, presence: true
  validates :day_full_adherence, presence: true
  validates :day_full_adherence2, presence: true
  validates :number_time_missing_pill, presence: true
end
