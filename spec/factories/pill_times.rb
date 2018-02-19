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

FactoryGirl.define do
  factory :pill_time do
    schedule
    monday    600
    tuesday   800
    wednesday 1000
    thursday  1200
    friday    1400
    saturday  1600
    sunday    1800
  end
end
