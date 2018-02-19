# == Schema Information
#
# Table name: notification_subscriptions
#
#  id                      :integer          not null, primary key
#  patient_id              :integer
#  notification_service_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class NotificationSubscription < ActiveRecord::Base
  belongs_to :patient
  belongs_to :notification_service

  validates :patient, presence: true
  validates :notification_service, presence: true

  accepts_nested_attributes_for :notification_service
end
