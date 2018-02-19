require 'spec_helper'

describe SmsService do
  let(:sms) { SmsService.new }
  let(:patient) { build(:patient, phone: '+6512345678') }

  it 'should get phone number' do
    expect(sms.phone('+6512345678')).to eq('+6512345678')
    expect(sms.phone(patient)).to eq('+6512345678')
  end
end
