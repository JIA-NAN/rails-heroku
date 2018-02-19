# == Schema Information
#
# Table name: pill_sequence_steps
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  step_no          :integer
#  meta             :string(255)
#  pill_sequence_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class PillSequenceStep < ActiveRecord::Base
  attr_accessible :meta, :name, :step_no, :pill_sequence

  # validations
  validate :name, :step_no, presence: true

  # relationships
  belongs_to :pill_sequence, touch: true

  # scopes
  default_scope -> { order('step_no ASC') }
end
