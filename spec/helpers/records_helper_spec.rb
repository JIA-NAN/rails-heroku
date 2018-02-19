require 'spec_helper'

describe RecordsHelper do
  context '#submission_time_diff' do
    let(:record) { double() }

    it 'should be on time' do
      record.stub pill_time_at: Time.zone.now,
                  created_at: Time.zone.now + 9.minutes
      expect(helper.submission_time_diff(record)).to match(/on time/i)
    end

    it 'should be early' do
      record.stub pill_time_at: Time.zone.now,
                  created_at: Time.zone.now - 19.minutes
      expect(helper.submission_time_diff(record)).to match(/early by 19 min/i)
    end

    it 'should be late' do
      record.stub pill_time_at: Time.zone.now,
                  created_at: Time.zone.now + 19.minutes
      expect(helper.submission_time_diff(record)).to match(/late by 19 min/i)
    end
  end

  context '#display_comment_name' do
    let(:record) { double() }

    it 'should be explanation' do
      record.stub(is_excuse?: false)
      expect(helper.display_comment_name(record)).to eq('Comment')
    end

    it 'should be comment' do
      record.stub(is_excuse?: true)
      expect(helper.display_comment_name(record)).to eq('Explanation')
    end
  end
end
