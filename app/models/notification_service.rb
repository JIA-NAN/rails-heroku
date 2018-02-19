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

class NotificationService < ActiveRecord::Base
  attr_accessible :name, :service

  validates :name, presence: true
  validates :service, presence: true, uniqueness: true

  has_many :notifications
  has_many :notification_subscriptions
  has_many :patients, through: :notification_subscriptions
end
