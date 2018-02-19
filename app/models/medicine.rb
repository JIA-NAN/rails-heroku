# == Schema Information
#
# Table name: medicines
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Medicine < ActiveRecord::Base
  attr_accessible :description, :name

  validates :name, :presence => true

  has_and_belongs_to_many :pill_times
end
