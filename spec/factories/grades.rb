# == Schema Information
#
# Table name: grades
#
#  id         :integer          not null, primary key
#  grade      :string(255)
#  comment    :text
#  record_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  admin_id   :integer
#  note       :text
#

FactoryGirl.define do
  factory :grade do
    grade Grade::SATISFY
    comment 'comment'
    note 'note'

    factory :grade_with_record do
      admin
      record
    end
  end
end
