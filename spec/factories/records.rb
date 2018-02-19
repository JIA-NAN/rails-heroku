# == Schema Information
#
# Table name: records
#
#  id                           :integer          not null, primary key
#  device                       :string(255)      default("unknown device")
#  comment                      :text
#  status                       :string(255)      default("pending")
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

FactoryGirl.define do
  factory :record do
    patient
    device 'iphone'
    comment 'comment'
    sequence(:pill_time_at) { |i| Time.zone.now.midnight + i.minutes }
    pill_sequence_id 1

    factory :yesterday_record do
      sequence(:pill_time_at) { |i| Time.zone.now.yesterday.midnight + i.minutes }
    end
  end
end
