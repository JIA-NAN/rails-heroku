# == Schema Information
#
# Table name: notification_services
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  service    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :notification_service do
    name 'A Notification Service'
    service 'System'

    factory :service_sms do
      name 'SMS'
      service 'Sms'
    end

    factory :service_push do
      name 'Push Notification'
      service 'Push'
    end
  end
end
