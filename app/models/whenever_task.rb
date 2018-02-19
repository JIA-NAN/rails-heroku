# == Schema Information
#
# Table name: whenever_tasks
#
#  id         :integer          not null, primary key
#  task       :string(255)
#  meta       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WheneverTask < ActiveRecord::Base
  attr_accessible :meta, :task

  TASKS = {
    miss_record: 'mark missed records',
    push_notify: 'push pill time notifications',
    send_notify: 'push scheduled notifications'
  }

  # Public: mark records that are missed
  #
  # Returns nothing.
  def self.mark_missed_records
    update_task :miss_record

    Patient.with_active_schedule.find_each(batch_size: 100) do |patient|
      MissingRecordChecker.mark_missed_record(patient)
    end
  end

  # Public: send pill time notifications
  #
  # Returns nothing.
  def self.push_notify_pill_times
    update_task :push_notify

    NotificationService.all.each do |provider|
      service = "#{provider.service}Service".constantize.new

      # get patients on pill time and subscribed this provider
      Notification.on_pill_times(provider).each do |time, patients|
        patients.each do |patient|
          service.send(patient, create_message(patient, time))
        end
      end
    end
  end

  # Public: send pill time notifications
  #
  # Returns nothing.
  def self.push_notify_scheduled
    update_task :send_notify

    Notification.to_send.find_each(batch_size: 500) do |notice|
      notice.deliver
    end
  end

  private

  # Internal: generate push notification messages
  #
  # time: in seconds
  #
  # Returns a message string
  def self.create_message(patient, time)
    time = time.to_i

    "Hi, #{patient.fullname} (#{patient.mist_id}). " <<
      # conditional messages
      if time > 0
        "Please take your pill within the next #{Ptime.to_time_distance(time)}."
      elsif time == 0
        "Please take your pill now."
      else
        "Your pill time has expired #{Ptime.to_time_distance(time)} ago. " +
        "You may submit a late record within the next #{Ptime.to_time_distance(time + 3.hours)}."
      end
  end

  # Internal: create an whenever task entry
  # Returns nothing.
  def self.update_task(task)
    WheneverTask.where(task: TASKS[task])
                .first_or_initialize
                .update_attributes(meta: "Updated on #{Ptime.now}")
  end

end
