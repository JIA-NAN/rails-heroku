# == Schema Information
#
# Table name: notifications
#
#  id                      :integer          not null, primary key
#  message                 :string(255)
#  sent                    :boolean          default(FALSE)
#  send_at                 :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  receiver                :string(255)
#  patient_id              :integer
#  notification_service_id :integer
#

class Notification < ActiveRecord::Base

  attr_accessible :receiver, :message, :send_at, :sent,
                  :patient_id, :notification_service_id

  # validations
  validates :receiver, presence: true
  validates :message,  presence: true, length: { in: 3..140 }
  validates :patient_id,  presence: true
  validates :notification_service_id, presence: true
  validate do
    if receiver.nil? && notification_service.service == 'Sms'
      errors.add(:notification_service_id, "No phone number configured")
    end
  end

  # relations
  belongs_to :patient
  belongs_to :notification_service

  # scopes
  scope :waiting, -> { where(sent: false) }
  scope :to_send, -> { waiting.where('send_at <= ?', Time.zone.now) }

  # delegate_to
  delegate :service, to: :notification_service
  delegate :fullname, to: :patient

  # hooks
  before_validation { self.receiver = patient.send("#{service.downcase}_id") }
  before_create -> { send_at = Time.zone.now if send_at.blank? }

  # paginate
  self.per_page = 10

  # Public: send current notification
  # Returns nothing.
  def deliver
    return if sent?

    begin
      provider = "#{service.capitalize}Service".constantize
      provider.new.send(receiver, message)

      update_attributes(sent: true)
    rescue NameError
      false
    end
  end

  # Public: get a list of patients who need push notify
  #
  # service - a NotificationService instance
  # options - options
  #
  # Return an object at different timing, with patients' mist_ids
  def self.on_pill_times(service, options = {})
    baskets = {}
    # initial baskets of each time slot
    time_slots.each { |time| baskets[time.to_s] = [] }

    # TODO optimize query
    service.patients
           .with_active_schedule
           .find_each(batch_size: 100) do |patient|
             time = patient.find_pill_notification(time_slots)
             receiver = options[:id] ? patient.send(options[:id]) : patient
             baskets[time.to_s].push(receiver) if time && receiver
           end

    baskets
  end

  private

  # TODO change this to be flexible
  def self.time_slots
    [30.minutes, 15.minutes, 0.minutes, -30.minutes, -1.hour, -2.hour]
  end

end
