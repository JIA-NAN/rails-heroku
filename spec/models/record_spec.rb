# == Schema Information
#
# Table name: records
#
#  id                           :integer          not null, primary key
#  device                       :string(255)      default('unknown device')
#  comment                      :text
#  status                       :string(255)      default('pending')
#  patient_id                   :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  video_file_name              :string(255)
#  video_content_type           :string(255)
#  video_file_size              :integer
#  video_updated_at             :datetime
#  audio_file_name              :string(255)
#  audio_content_type           :string(255)
#  audio_file_size              :integer
#  audio_updated_at             :datetime
#  video_processing             :boolean
#  meta                         :text
#  pill_sequence_id             :integer
#  video_s3_file_name           :string(255)
#  video_s3_content_type        :string(255)
#  video_s3_file_size           :integer
#  video_s3_updated_at          :datetime
#  pill_time_at                 :datetime
#  video_steplized_file_name    :string(255)
#  video_steplized_content_type :string(255)
#  video_steplized_file_size    :integer
#  video_steplized_updated_at   :datetime
#  meta_steplized               :string(255)
#

require 'spec_helper'

describe Record do
  it 'should has default status pending' do
    record = build(:record)
    expect(record.status).to eq(Record::PENDING)
  end

  it 'should validate no duplicated records' do
    now = Time.zone.now
    patient = create(:patient)

    record = build(:record, patient: patient, pill_time_at: now)
    expect(record.valid?).to be_true

    record.save
    record = build(:record, patient: patient, pill_time_at: now)
    expect(record.valid?).to be_false
    expect(record.errors.messages[:pill_time_at].join).to match(/duplicated/)
  end

  it 'should remove cutoff missing record' do
    now = Time.zone.now
    patient = create(:patient)

    create(:record, patient: patient, status: Record::MISSING, pill_time_at: now)
    expect(patient.records.count).to eq(1)
    expect(patient.records.status(Record::MISSING).count).to eq(1)

    create(:record, patient: patient, pill_time_at: now)
    expect(patient.records.count).to eq(1)
    expect(patient.records.status(Record::MISSING).count).to eq(0)
  end

  context '#steps' do
    it '#steps return an array of timestamps' do
      record = build(:record, meta: '1.0,1.5,2.3')
      expect(record.steps).to eq([1.0, 1.5, 2.3])

      record = build(:record, meta: '')
      expect(record.steps).to eq([])
    end

    it '#steps return an empty array' do
      record = build(:record, meta: nil)
      expect(record.steps).to eq([])
    end

    it '#steplized_steps return an array of timestamps' do
      record = build(:record, meta_steplized: '1.0,1.5,2.3')
      expect(record.steplized_steps).to eq([1.0, 1.5, 2.3])

      record = build(:record, meta_steplized: '')
      expect(record.steplized_steps).to eq([])
    end

    it '#steplized_steps return fallback to #steps' do
      record = build(:record, meta: '1.0,1.5,2.3')
      expect(record.steplized_steps).to eq([1.0, 1.5, 2.3])
    end
  end

  it '#is_excuse? iff it is missing/excused/onhold_excuse' do
    each_record_statuses do |status|
      record = build(:record, status: status)
      expect(record.is_excuse?).to be_false
    end

    each_excuse_statuses do |status|
      record = build(:record, status: status)
      expect(record.is_excuse?).to be_true
    end
  end

  it '#require_grading? if it is pending' do
    record = build(:record)
    expect(record.require_grading?).to be_true
  end

  it '#require_grading? if it is a commented ungraded excuse' do
    record = build(:record, comment: 'a', status: Record::MISSING)
    expect(record.require_grading?).to be_true

    record = build(:record, comment: '', status: Record::MISSING)
    expect(record.require_grading?).to be_false

    record = build(:record, comment: ' ', status: Record::MISSING)
    expect(record.require_grading?).to be_false

    record = build(:record, comment: nil, status: Record::MISSING)
    expect(record.require_grading?).to be_false
  end

  it 'not #require_grading? if it is not pending or commented excuse' do
    each_record_statuses(Record::PENDING) do |status|
      record = build(:record, status: status)
      expect(record.require_grading?).to be_false
    end

    each_excuse_statuses(Record::MISSING) do |status|
      record = build(:record, status: status)
      expect(record.require_grading?).to be_false
    end
  end

  context '#post_processing' do
    let(:record) { build(:record) }

    it 'should skip if video is nil' do
      expect(record).to_not receive(:require_merge?)
      record.post_processing
    end

    it 'should merge if it has audio' do
      record.stub(video: double())
      record.stub(audio: double())

      expect(record).to receive(:merge_audio_to_video).once
      expect(record).to receive(:rotate_video).exactly(0).times
      expect(record).to receive(:steplized_steps).exactly(0).times

      record.post_processing
    end

    it 'should rotate if it only has video' do
      record.stub(video: double())

      expect(record).to receive(:merge_audio_to_video).exactly(0).times
      expect(record).to receive(:rotate_video).once
      expect(record).to receive(:steplized_steps).exactly(0).times

      record.post_processing
    end

    it 'should steplize if it has meta' do
      record.stub(video: double())
      record.meta = '1,2,3,4,5'

      expect(record).to receive(:merge_audio_to_video).exactly(0).times
      expect(record).to receive(:rotate_video).once
      expect(record).to receive(:steplize_video).once

      record.post_processing
    end
  end

  it '#onhold mark status onhold' do
    each_record_statuses do |status|
      record = build(:record, status: status)
      record.onhold
      expect(record.status).to eq(Record::ONHOLD)
    end

    each_excuse_statuses do |status|
      record = build(:record, status: status)
      record.onhold
      expect(record.status).to eq(Record::ONHOLD_EXCUSE)
    end
  end

  it '#graded change status to graded' do
    [Record::PENDING, Record::ONHOLD].each do |status|
      record = build(:record, status: status)
      record.graded
      expect(record.status).to eq(Record::GRADED)
    end
  end

  it '#graded change status to excused' do
    [Record::MISSING, Record::ONHOLD_EXCUSE].each do |status|
      record = build(:record, status: status)
      record.graded
      expect(record.status).to eq(Record::EXCUSED)
    end
  end

  it '#ungraded change status to pending' do
    [Record::GRADED, Record::ONHOLD].each do |status|
      record = build(:record, status: status)
      record.ungraded
      expect(record.status).to eq(Record::PENDING)
    end
  end

  it '#ungraded change status to missing' do
    [Record::EXCUSED, Record::ONHOLD_EXCUSE].each do |status|
      record = build(:record, status: status)
      record.ungraded
      expect(record.status).to eq(Record::MISSING)
    end
  end

  def each_record_statuses(*except)
    [Record::PENDING, Record::GRADED, Record::VERIFIED, Record::ONHOLD].each do |status|
      yield status unless except.include?(status)
    end
  end

  def each_excuse_statuses(*except)
    [Record::MISSING, Record::EXCUSED, Record::ONHOLD_EXCUSE].each do |status|
      yield status unless except.include?(status)
    end
  end
end
