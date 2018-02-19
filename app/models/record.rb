# == Schema Information
#
# Table name: records
#
#  id                           :integer          not null, primary key
#  device                       :string(255)      default("unknown device")
#  comment                      :text

#  status                       :string(255)      default("pending")

#  received                     :boolean
#  graded                       :boolean

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
require 'open-uri'
require 'rubygems'
require 'aws/s3'
require 'securerandom'
require 'openssl'
require 'zip'
require 'json'

class Record < ActiveRecord::Base
  # status of record
  #   pending  = submitted, waiting for grading/reviewing
  #   graded  = record exists, can be graded as either satisfactory, or unsatisfactory
  #   missing  = record missing, can be graded as either nonadherence, or excused
  #   verified = graded by the system algorithms
  ANDROID_PHONE = 'Linux armv7l'.freeze
  TMP_DIR = '/app/tmp'
  #
  # STATUS_TYPES and status are now defunct.
  # Use received and graded to indicate if records been received and graded,
  # and Grade record to store the results -- ooiwt
  #
  #STATUS_TYPES =   %w(received-swallowed,
  #    received-not-swallowed,
  #    received-unclear,
  #    received-pending,
  #    missing-technical-swallowed,
  #    missing-technical-not-swallowed,
  #    missing-explained-swallowed,
  #    missing-explained-not-swallowed,
  #    missing-unexplained,
  #    missing-pending)
  #    RECEIVED_SWALLOWED, RECEIVED_NOT_SWALLOWED, RECEIVED_UNCLEAR, RECEIVED_PENDING,
  #    MISSING_TECHNICAL_SWALLOWED, MISSING_TECHNICAL_NOT_SWALLOWED,
  #    MISSING_EXPLAINED_SWALLOWED, MISSING_EXPLAINED_NOT_SWALLOWED,
  #    MISSING_UNEXPLAINED, MISSING_PENDING = STATUS_TYPES

  attr_accessible :comment, :device, :video, :audio, :meta, :meta_steplized, :patient_id,
    :video_s3, :video_file_name, :video_steplized, :video_processing,
    :video_steplized_file_name, :received, :graded, :pill_time_at,
    :side_effect_ids, :pill_sequence_id, :actual_pill_time_at

  # video and audio
  # Using Paperclip library.  The attribute video_file_name are generated.
  has_attached_file :video,
    storage: :filesystem,
    url: '/:class/:attachment/:id_partition/:style/:filename',
    preserve_file: true

  has_attached_file :audio
  has_attached_file :video_s3,
    storage: :s3,
    s3_credentials: Rails.root.join('config/aws_s3.yml'),
    s3_protocol: :https,
    url: ':s3_domain_url',
    path: '/:class/:attachment/:id_partition/:style/:filename',
    bucket: Proc.new { || Rails.env == 'production' ? 'mist-prod' : 'mist-dev' }

  has_attached_file :video_steplized,
    storage: :s3,
    s3_credentials: Rails.root.join('config/aws_s3.yml'),
    url: ':s3_domain_url',
    path: '/:class/:attachment/:id_partition/:style/:filename',
    bucket: Proc.new { || Rails.env == 'production' ? 'mist-prod' : 'mist-dev' }

  # set default attributes
  before_validation :set_default_attr
  def set_default_attr
    #self.status ||= SUBMITTED
    self.received ||= false
    self.graded ||= false
    self.pill_time_at ||= patient.current_schedule.nearest_pill_time(self.actual_pill_time_at)
    self.side_effect_ids ||= []
  end

  # validations
  #validates :status, presence: true, inclusion: { in: STATUS_TYPES }
  validates :patient_id, presence: true
  validates :pill_time_at, presence: true
  # validates :actual_pill_time_at , presence: true
  # attachment validations
  validates_attachment :video, content_type: { content_type: ['video/mpeg', 'video/mp4',
                                                              'application/mp4', 'video/webm',
                                                              'video/mov'] }
  validates_attachment :audio, content_type: { content_type: ['audio/mpeg', 'audio/wav',
                                                              'audio/ogg'] }
  # duplication submission
  validate :no_duplicated_submission, if: -> { self.new_record? }
  def no_duplicated_submission
    if patient.records.where(pill_time_at: pill_time_at).count > 0
      errors.add(:pill_time_at, "can't has duplicated submissions")
    end
  end

  # hooks
  after_create :remove_cutoff_marked_submission, if: -> { received == true }
  def remove_cutoff_marked_submission
    patient.records.where(pill_time_at: pill_time_at, received: false).each(&:destroy)
  end

  before_save :run_before_save
  after_create :run_after_create

  def run_before_save
    if video_s3.size
      self.received = true
    else
      self.received = false
    end
    true
  end

  def run_after_create
    puts 'run after create'
    if self.received
      self.delay.process_video
    end
    true
  end

  # relationships
  belongs_to :patient
  belongs_to :pill_sequence
  has_one :grade, dependent: :destroy
  has_one :auto_grade, dependent: :destroy
  has_and_belongs_to_many :side_effects

  # paginate
  self.per_page = 10

  # scopes
  default_scope -> { order('records.created_at DESC') }
  #scope :status, ->(value) { where(status: value) if STATUS_TYPES.include?(value) }
  scope :pill_time, ->(time) { where(pill_time_at: time.in_time_zone) }
  # range scopes
  scope :submissions_from_today, -> { where(pill_time_at: Time.zone.now.midnight.in_time_zone..Time.zone.now.tomorrow.midnight.in_time_zone, received: true) }

  scope :from_today, -> { from_period(Time.zone.now, Time.zone.now.tomorrow) }
  scope :from_date, ->(date) { date == :today ? from_today : where(pill_time_at: date.beginning_of_day.in_time_zone..date.end_of_day.in_time_zone) }
  scope :from_month, ->(date) { from_period(date.at_beginning_of_month, date.at_end_of_month) }
  scope :from_period, ->(from, to) { where(pill_time_at: from.midnight.in_time_zone..to.midnight.in_time_zone) }
  # property scopes
  scope :not_on_s3, -> { where('video_s3_file_name IS NULL AND video_file_name IS NOT NULL') }
  scope :not_processed, -> { where('audio_file_name IS NOT NULL') } # not merged
  scope :steplized, -> { where('video_steplized_file_name IS NOT NULL') }
  scope :not_steplized, -> { where('video_steplized_file_name IS NULL AND video_file_name IS NOT NULL AND meta IS NOT NULL') }

  # get steps' timestamps in array
  def steps
    meta ? meta.split(',').map(&:to_f) : []
  end

  # get record's video path
  def video_url
    if video_s3.size
      video_s3.url
    elsif video.size
      video.url
    end
  end

  # get steplized steps' timestamps in array
  def steplized_steps
    if meta_steplized
      meta_steplized.split(',').map(&:to_f)
    else
      steps
    end
  end

  # get record's steplized video url
  def url_to_steplized_video
    if video_steplized.size
      video_steplized.url
    else
      video_url
    end
  end

  # determine whether record is an excuse
  def is_excuse?
    # XXX: TODO
    return true
    #[MISSING].include? status
  end

  # determine whether grading is required
  def require_grading?
    #status == PENDING || (status == NONADHERENCE && !comment.blank?)
    #status == SUBMITTED
    graded == false
  end

  # on hold
  def onhold
    update_attributes(graded: false)
  end

  # graded
  def set_graded
    update_attributes(graded: true)
    #case status
    #when PENDING
    #  update_attributes(status: PENDING)
    #when GRADED
    #  update_attributes(status: GRADED)
    #when VERIFIED
    # TODO now stay verified
    #end
  end

  # ungraded
  def set_ungraded
    update_attributes(graded: false)
    #case status
    #when GRADED, MISSING
    #  update_attributes(status: SUBMITTED)
    #when VERIFIED
    #  # TODO now stay verified
    #end
  end

  # determine whether merging is required
  def require_merge?
    !audio.blank? && !video_processing?
  end

  # determine whether recording device is Android Phone
  def is_android_phone
    self.device.eql? ANDROID_PHONE
  end

  # post processing
  def post_processing
    return if video.blank? # video must exists

    update_frames = require_merge?

    if require_merge? # web
      # if isAndroidPhone #android phone
      #   swap_uv_attribute
      # end
      merge_audio_to_video
    else # ios
      rotate_video
    end

    # for web, update fps when steplizing
    steplize_video(update_frames: update_frames) unless meta.nil?
  end

  #swap U,V Attribute here
  def swap_uv_attribute
    swap = VideoProcessor.new(video.path).swap
    if swap.succeed?
      new_video = File.new swap.outputs.last
      if Rails.env == 'production'
        update_attributes(video: new_video, video_s3: new_video, video_processing: false)
      else
        update_attributes(video: new_video, video_s3: nil, video_processing: false)
      end
      new_video.close
    else
      update_attributes(video_processing: false)
    end
  end

  # merge webm and wav to mp4 using ffmpeg
  def merge_audio_to_video
    return unless require_merge?
    update_attributes(video_processing: true)
    merge_audio_to_video!
  end

  # merge webm and wav to mp4 using ffmpeg even it is processing
  def merge_audio_to_video!
    merge = VideoProcessor.new(video.path).merge(audio.path)

    if merge.succeed?
      sleep 1 # wait for 1s just in case

      new_video = File.new merge.outputs.last
      if Rails.env == 'production'
        update_attributes(video: new_video, video_s3: new_video, audio: nil, video_processing: false)
      else
        update_attributes(video: new_video, video_s3: nil, audio: nil, video_processing: false)
      end

      new_video.close
    else
      update_attributes(video_processing: false)
    end
  end

  # rotate video clockwise by 90 degrees
  def rotate_video
    return if video_processing?
    update_attributes video_processing: true
    rotate = VideoProcessor.new(video.path).rotate
    if rotate.succeed?
      sleep 1 # wait for 1s just in case
      new_video = File.new rotate.outputs.last
      if Rails.env == 'production'
        update_attributes(video: new_video, video_s3: new_video, audio: nil,
                          video_processing: false)
      else
        update_attributes(video: new_video, audio: nil,
                          video_processing: false)
      end
      new_video.close
    else
      update_attributes(video_processing: false)
    end
  end

  # steplize video
  def steplize_video(options = {})
    return if video_processing?
    update_attributes video_processing: true
    steplize_video!(options)
  end

  def steplize_video!(options = {})
    steplizer = VideoSteplizer.new video.path, "#{Time.zone.now.to_i}.mp4", steps, options
    if steplizer.execute
      sleep 1 # wait for 1s just in case
      new_video = File.new steplizer.output
      update_attributes(video_steplized: new_video,
                        meta_steplized: steplizer.step_meta,
                        video_processing: false)
      new_video.close
    else
      update_attributes(video_processing: false)
    end
  end

  def save_to_s3
    update_attributes(video_s3: video)
  end

  def from_patient_on_date(patient, date)
    return Record.where(patient: patient).from_date(date)
  end

  # When a video is uploaded,  run_after_create callback will call self.delay.process_video
  # which puts process_video job into queue of delayed jobs
  # process_video will download video from Amazon S3, generate sreenshots, do face recognition
  # and pill tracking.

  def process_video
    self.auto_grade ||= AutoGrade.new
    if self.video_s3.exists?
      # download the encrypted video from Amazon s3
      download = open(video_url)
      IO.copy_stream(download, "#{TMP_DIR}/video#{self.id}")
      # bucket_name = ENV.fetch('S3_BUCKET_NAME')
      access_key_id = ENV.fetch('S3_ACCESS_KEY')
      secret_access_key = ENV.fetch('S3_SECRET_ACCESS_KEY')
      region = ENV.fetch('S3_REGION')
      AWS.config(access_key_id: access_key_id, secret_access_key: secret_access_key, region: region)
      # s3 = AWS::S3.new

      # decrypt the downloaded video

      key = ENV.fetch('CIPHER_KEY')

      cipher = OpenSSL::Cipher.new('AES-128-ECB')
      cipher.decrypt
      cipher.key = [key].pack('H*')
      buf = ''
      File.open("#{TMP_DIR}/video#{self.id}_decrypt", 'wb') do |outf|
        File.open("#{TMP_DIR}/video#{self.id}", 'rb') do |inf|
          while inf.read(4096, buf)
            outf << cipher.update(buf)
          end
          outf << cipher.final
        end
      end

      rotation = `./exiftool/exiftool -rotation #{TMP_DIR}/video#{self.id}_decrypt`
      rotation = rotation.split(':').last.strip
      generate_screenshots("#{TMP_DIR}/video#{self.id}_decrypt", rotation)
      # if patient has uploaded photo, then do face recognition
      if patient.photo.exists?
        face_recognition("#{TMP_DIR}/video#{self.id}_decrypt", rotation)
        # if face is recognized, then do pill tracking
        if self.is_face_recognized
          pill_tracking("#{TMP_DIR}/video#{self.id}_decrypt", rotation)
        end
      end
    end
  end

  # check if the face on the video is correct patient
  def face_recognition(decrypted_video_path, rotation)
    # download the encrypted photo of the patient from Amazon s3
    download = open(patient.photo_url)

    IO.copy_stream(download, "#{TMP_DIR}/photo#{self.id}")

    # decrypt the photo
    key = ENV.fetch('CIPHER_KEY')
    cipher = OpenSSL::Cipher.new('AES-128-ECB')
    cipher.decrypt
    cipher.key = [key].pack('H*')

    buf = ''
    File.open("#{TMP_DIR}/photo#{self.id}_decrypt", 'wb') do |outf|
      File.open("#{TMP_DIR}/photo#{self.id}", 'rb') do |inf|
        while inf.read(4096, buf)
          outf << cipher.update(buf)
        end
        outf << cipher.final
      end
    end

    # run face_recognition.py
    output = `python ./python_script/face_recognition.py #{decrypted_video_path} #{TMP_DIR}/photo#{self.id}_decrypt  #{rotation}`
    begin
      result = JSON.parse(output)
      self.auto_grade.is_face_recognized = result['is_face_recognized']
      self.auto_grade.face_recognition_score = result['face_recognition_score']
      self.auto_grade.save
    rescue JSON::ParserError
      puts 'json error'
    end

    File.delete("#{TMP_DIR}/photo#{self.id}_decrypt") if File.exist?("#{TMP_DIR}/photo#{self.id}_decrypt")
    File.delete("#{TMP_DIR}/photo#{self.id}") if File.exist?("#{TMP_DIR}/photo#{self.id}")
  end

  # check if patient puts pill with correct color into the open mouth

  def pill_tracking(decrypted_video_path, rotation)
    # pill_rect: the position of the pill area
    # upper_pill_color, lower_pill_color is the upper color and lower color of the pill in hsv space
    # they are fixed for now but should change according to the pill

    pill_rect = '(10,900,200,200)'
    upper_pill_color = '(30 ,255 ,255)'
    lower_pill_color = '(20, 100, 100)'
    exe = 'python ./python_script/pill_tracking.py'
    output = `#{exe} #{decrypted_video_path} #{rotation} \"#{pill_rect}\" \"#{upper_pill_color}\" \"#{lower_pill_color}\"`
    if output == 'true'
      self.auto_grade.is_pill_taken = true
    else
      self.auto_grade.is_pill_taken = false
    end
    self.auto_grade.save

    # delete video and decrypted video
    File.delete(decrypted_video_path) if File.exist?(decrypted_video_path)
    File.delete("#{TMP_DIR}/video#{self.id}") if File.exist?("#{TMP_DIR}/video#{self.id}")
  end

  # generate screenshots of important moments for the videos
  def generate_screenshots(decrypted_video_path, rotation)
    bucket_name = ENV.fetch('S3_BUCKET_NAME')
    access_key_id = ENV.fetch('S3_ACCESS_KEY')
    secret_access_key = ENV.fetch('S3_SECRET_ACCESS_KEY')
    region = ENV.fetch('S3_REGION')

    AWS.config(access_key_id: access_key_id, secret_access_key: secret_access_key, region: region)

    s3 = AWS::S3.new
    screenshot_folder = "screenshot#{self.id}"
    key = ENV.fetch('CIPHER_KEY')

    # run screenshots.py
    screenshot_py = './python_script/screenshots.py'
    output_dir = "#{TMP_DIR}/output/#{screenshot_folder}"
    output = `python #{screenshot_py} #{decrypted_video_path} #{output_dir} #{rotation}`

    puts output
    path_array = output.split("\n")

    # zip the screenshots
    zipfile_name = "#{TMP_DIR}/output/#{screenshot_folder}.zip"
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      path_array.each do |screenshot_path|
        if screenshot_path.include? 'jpg'
          filename = File.basename(screenshot_path)
          zipfile.add(filename, screenshot_path)
        end
      end
    end
    # encrypt the zip file
    cipher = OpenSSL::Cipher.new('AES-128-ECB')
    cipher.encrypt
    cipher.key = [key].pack('H*')

    buf = ''
    File.open("#{zipfile_name}_encrypt", 'wb') do |outf|
      File.open(zipfile_name, 'rb') do |inf|
        while inf.read(4096, buf)
          outf << cipher.update(buf)
        end
        outf << cipher.final
      end
    end

    # upload zip file to amazon s3
    bucket = s3.buckets[bucket_name]
    folder = bucket.objects["screenshots/#{screenshot_folder}"]
    object = folder..write(file: "#{zipfile_name}_encrypt")

    File.delete(zipfile_name) if File.exist?(zipfile_name)

    File.delete("#{zipfile_name}_encrypt") if File.exist?("#{zipfile_name}_encrypt")
    path_array.each do |screenshot_path|
      if screenshot_path.include? 'jpg'
        File.delete(screenshot_path) if File.exist?(screenshot_path)
      end
    end
    self.screenshot_urls = '' + object.public_url.to_s
    self.save
  end
end
