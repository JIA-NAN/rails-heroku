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

class Schedule < ActiveRecord::Base
  attr_accessible :started_at, :terminated_at, :patient_id

  validates :started_at, presence: true
  validates :terminated_at, presence: true
  validate  :terminated_date_should_after_started_date

  belongs_to :patient, touch: true
  has_many :pill_times, dependent: :destroy

  # paginate
  self.per_page = 10

  # scopes
  scope :active, -> do
     where('started_at <= ?', Time.zone.today)
    .where('terminated_at IS NULL or terminated_at > ?', Time.zone.today)
    .order('created_at DESC')
  end

  # Public: get all the pill times from a day/date
  #
  # day - :today, :tomorrow, :monday .. :sunday,
  #       or a specific date
  #
  # Return an array of pill times in order
  def pill_times_from(day)
    weekday = day == :today ? Ptime.weekday_today :
              day == :tomorrow ? Ptime.weekday_tomorrow :
              day == :yesterday ? Ptime.weekday_yesterday :
              day.respond_to?(:in_time_zone) ?
              Ptime.weekday_of(date) : day

    pill_times.map { |p| p[weekday] }.sort
  end

  # Public: get the nearest pill time near a time specified,

  #  If patient take a pill n times at time t_1, .. t_n, then the time window for pill time at t_i is
  #  (t_i - (t_i - t_{i-1}/2) .. t_i + (t_i - t_{i+1}/2)
  #         
  #
  #  time - the time point, default: Time.zone.now
  #
  # Return nil or a datetime
  def nearest_pill_time(time = nil)
    time ||= Time.zone.now

    to_time = proc { |d| lambda { |t| Ptime.to_time(t, d) } }
    # select pill time candidates from within periods
    candidates =
      pill_times_from(:yesterday).map(&to_time.call(time.yesterday)) +
      pill_times_from(:today).map(&to_time.call(time)) +
      pill_times_from(:tomorrow).map(&to_time.call(time.tomorrow))



     if candidates.length == 0

      return nil 

    end 

    if time <= candidates.first - 12.hour 

      return nil 

    end 

    if time > candidates.first - 12.hour and time <= candidates.first

      return candidates.first

    end 


    if time >= candidates.last + 12.hour

      return nil

    end 

    if time < candidates.last + 12.hour and time >= candidates.last

      return candidates.last

    end 

    if candidates.length == 1

      return candidates.first

    end 


    candidates.each_with_index {|val, index| 


      if index < candidates.length - 1 then 

        next_val = candidates[index+1]


        if time >= val and time <= val + (next_val - val) / 2

          return val 

        elsif time > val  + (next_val - val) / 2 and time <= next_val

          return next_val

        end 


      end 
      

    }


  end

  # Public: get the future pill time after 1 hour from now
  #
  # Return { :time => pill time, :date => :today|:tomorrow }
  def future_pill_time
    today = pill_times_from(:today).find { |t| Ptime.seconds_to_now(t) > 1.hour }

    if today
      return { time: today, date: :today }
    else
      return { time: pill_times_from(:tomorrow).first, date: :tomorrow }
    end
  end

  # Public: get the max pill delay time.
  #         it is specified as 3 hours now
  #
  # Return time in seconds
  def pill_delay_time
    3.hours
  end

  private

  def terminated_date_should_after_started_date
    if terminated_at && terminated_at <= started_at
      errors.add(:terminated_at, "can't be earlier than started date")
    end
  end
end
