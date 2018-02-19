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

FactoryGirl.define do
  factory :schedule do
    patient
    started_at { 1.week.ago.to_date }
    terminated_at { 1.week.from_now.to_date }

    factory :schedule_in_past do
      started_at { 1.month.ago.to_date }
      terminated_at { 1.week.ago.to_date }
    end

    factory :schedule_in_future do
      started_at { 1.week.from_now.to_date }
      terminated_at { 1.month.from_now.to_date }
    end
  end
end
