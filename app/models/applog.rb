# == Schema Information
#
# Table name: applogs
#
#  id         :integer          not null, primary key
#  device     :string(255)
#  version    :string(255)
#  content    :string(255)
#  level      :string(255)
#  identifier :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Applog < ActiveRecord::Base
  LEVELS = %w(error warn info debug trace)

  attr_accessible :content, :device, :identifier, :level, :version

  # validations
  validates :device, presence: true
  validates :content, presence: true
  validates :level, presence: true, inclusion: { in: LEVELS }

  # paginate
  self.per_page = 30

  # sccopes
  default_scope -> { order('created_at DESC') }
  scope :level, ->(level) { where(level: level) if LEVELS.include?(level) }
end
