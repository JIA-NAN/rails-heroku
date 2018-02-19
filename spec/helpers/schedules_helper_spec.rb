require 'spec_helper'

describe SchedulesHelper, :type => :helper do
  context '#format_time' do
    it 'get nil default' do
      expect(helper.format_time(nil)).to eq('0900')
    end

    it 'get 0 shifted in' do
      expect(helper.format_time(900)).to eq('0900')
    end

    it 'get the same as input' do
      expect(helper.format_time(2300)).to eq('2300')
    end
  end
end
