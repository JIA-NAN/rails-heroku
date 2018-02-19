# == Schema Information
#
# Table name: roles
#
#  id          :integer          not null, primary key
#  name        :string(255)      default("User"), not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Role < ActiveRecord::Base
  attr_accessible :description, :name

  validates :name, :presence => true

  has_and_belongs_to_many :admins
end
