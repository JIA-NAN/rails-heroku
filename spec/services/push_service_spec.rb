require 'spec_helper'

describe PushService do
  let(:push) { PushService.new }
  let(:patient) { build(:patient) }

  it 'should get push channels' do
    expect(push.channels(%w(1 2))).to eq(%w(1 2))
    expect(push.channels('+6512345678')).to eq(['+6512345678'])
    expect(push.channels(patient)).to eq([patient.mist_id_for_push])
  end
end
