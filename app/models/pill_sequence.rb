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

class PillSequence < ActiveRecord::Base
  attr_accessible :default, :name

  # validations
  validate :name, presence: true

  # relationships
  has_many :pill_sequence_steps, dependent: :destroy
  has_many :records

  # scopes
  scope :default, -> { where(default: true) }

  # hooks
  def only_one_default_sequence
    if PillSequence.default.count > 0
      PillSequence.default.each do |seq|
        seq.update_attributes(default: false)
      end
    end
  end
  before_save :only_one_default_sequence, if: -> { default_changed? && default == true }

  # Public: get sequence steps in order
  #
  # Returns an array of steps object
  def steps
    Rails.cache.fetch([self, "pill_sequence_steps"]) { pill_sequence_steps }
  end

  # Public: pick a sequence from all pill sequences
  #         return the default or a random sequence
  #
  # Returns a sequence with steps
  def self.pick_one
    self.default.first || self.offset(rand(self.count)).first
  end

end
