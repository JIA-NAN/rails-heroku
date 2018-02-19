# == Schema Information
#
# Table name: pill_sequences
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  default    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :PillSequence do
    name 'pill sequence'
    default false
  end
end
