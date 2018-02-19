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

require 'spec_helper'

describe PillSequence do
  it '#steps return steps in sequence' do
    expect(create(:PillSequence).steps).to eq([])
  end

  it '#pick_one return a sequence' do
    seq = create(:PillSequence)
    expect(PillSequence.pick_one).to eq(seq)
  end

  it '#pick_one return the default sequence if exists' do
    seq = create(:PillSequence, default: true)
    expect(PillSequence.pick_one).to eq(seq)
  end

  it 'ensure #only_one_default_sequence when new default created' do
    seq1 = create(:PillSequence, default: true)
    expect(PillSequence.default).to eq([seq1])

    seq2 = create(:PillSequence, default: true)
    expect(PillSequence.default).to eq([seq2])
  end

  it 'ensure #only_one_default_sequence when new default saved' do
    seq1 = create(:PillSequence, default: true)
    expect(PillSequence.default).to eq([seq1])

    seq2 = create(:PillSequence)
    expect(PillSequence.default).to eq([seq1])

    seq2.update_attributes(default: true)
    expect(PillSequence.default).to eq([seq2])
  end
end
