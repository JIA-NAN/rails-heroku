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

FactoryGirl.define do
  factory :notification, class: Notification do
    patient
    receiver '+6510000001'
    message 'message'
  end
end
