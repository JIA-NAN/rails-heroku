# == Schema Information
#
# Table name: patients
#
#  id                     :integer          not null, primary key
#  firstname              :string(255)      not null
#  lastname               :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  authentication_token   :string(255)
#  mist_id                :string(255)      default(""), not null
#  phone                  :string(255)
#
require 'openssl'
require 'base64'

class Patient < ActiveRecord::Base
  # default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, authentication_keys: [:login]

  # virtual attribute for authenticating by either username or email
  # this is in addition to a real persisted field like 'username'
  attr_accessor :login

  attr_accessible :firstname, :lastname, :mist_id,
                  :phone, :email, :remember_me, :login,
                  :notification_service_ids, :wallet_balance,
                  :password, :password_confirmation, :photo

  # validations
  validates :firstname, :lastname, presence: true
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: /^.+@.+\..+$/ }
  validates :phone, format: { with: /^\+\d{8,12}$/ }, uniqueness: true, unless: -> { phone.blank? }

  # relations
  has_many :records, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :grades, through: :records
  has_many :notifications, dependent: :destroy
  has_many :notification_subscriptions, dependent: :destroy
  has_many :notification_services, through: :notification_subscriptions
  has_many :wallet_transactions, dependent: :destroy

  has_attached_file :photo, storage: :s3, :styles => {:original => {}},
    s3_credentials: Rails.root.join("config/aws_s3.yml"),
    :s3_protocol => :https,
    url: ":s3_domain_url",
    path: "/:class/:attachment/:id_partition/:style/:filename",
    bucket: Proc.new { |a| Rails.env == 'production' ? 'mist-prod' : 'mist-dev' }

  # hooks
  after_create :create_mist_id

  # scope
  scope :with_active_schedule, -> do
    joins(:schedules)
      .where('schedules.started_at <= ?', Time.zone.today)
      .where('terminated_at IS NULL or terminated_at >= ?', Time.zone.today).uniq
  end
  # patient's state
  scope :state, ->(state) do
    with_active_schedule if state == 'active'
  end
  # patient's service enabled
  scope :enabled, ->(service) do
    joins(:notification_services)
      .where("notification_services.service = ?", service)
  end

  # paginate
  self.per_page = 10

  # Get a mist id for push notification
  def mist_id_for_push
    "user_#{mist_id}"
  end

  # notification ids
  alias_method    :push_id, :mist_id_for_push
  alias_attribute :sms_id, :phone
  alias_attribute :email_id, :email

  # Public: Get the fullname in format
  def fullname(format = :default)
    case format
    when :default
      "#{firstname.capitalize} #{lastname.upcase}"
    when :dashed
      "#{firstname.downcase}_#{lastname.downcase}"
    end
  end

  # Public: get patient's current schedule
  #
  # Return current schedule, which is not terminated
  # or terminated_at a date after today, sort by created_at
  def current_schedule
    Rails.cache.fetch([self, "current_schedule"]) do
      schedules.active.includes(:pill_times).first
    end
  end

  # Public: get current pill time at this point of time.
  #         current pill time defined as in 1 hour time from the specified time,
  #         or not beyond the delay time after the specified time.
  #
  # Return nil or a datetime of pill time
  def current_pill_time
    return nil if current_schedule.nil?
    return @current_pill_time if defined?(@current_pill_time)

    time = current_schedule.nearest_pill_time

    @current_pill_time ||= if time && records.pill_time(time).count == 0
                             time
                           end
  end

  # Public: get the next record time of a date according to the submissions and
  #         required pills.
  #
  # date - :today, :yesterday, :tomorrow, or a specific datetime
  #
  # Return nil or next record time, which is the next pill time
  # of the date that without a record/excuse attached
  def next_record_time(date = :today)

   return nil if current_schedule.nil?

    pill_times = current_schedule.pill_times_from(date)
    return nil if pill_times.blank?

    date = Ptime.word_to_time(date)
    return pill_times[0] if date.in_time_zone.future?

    records_length = records.from_date(date).count
    return pill_times[records_length] if records_length < pill_times.length
    
  end

  # Public: check pill time notification
  #
  # notification_times - an array of notification times
  #
  # Examples
  #
  # find_pill_notification([-10.minutes, 0.minutes, 10.minutes])
  #
  # Return nil or a notification time if matched
  def find_pill_notification(notification_times)
    record_time = current_pill_time

    unless record_time.nil?
      time_diff = Ptime.seconds_to_now(record_time)
      time_period = ((time_diff - 3.minutes)..(time_diff + 3.minutes))

      notification_times.find do |time|
        time_period.include? time
      end
    end
  end

  # Add mist_id as one of login parameters
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup

    if login = conditions.delete(:login)
      where(conditions).where(['lower(mist_id) = :value OR lower(email) = :value',
                              { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |patient|
        csv << patient.attributes.values_at(*column_names)
      end
    end
  end


    def update_wallet
      # No reward available
      if RewardRule.count == 0
        return 0
      end
      @reward_rule = RewardRule.first()
      # First, use adherence presenter to calculate how much money this patient
      # gained.
      @ap = AdherencePresenter.new(self)
      earliest_date = Date.new(2071, 1, 1)
      latest_date = Date.new(1971, 1, 1)
      self.schedules.each do |s|
        if s.started_at < earliest_date
          earliest_date = s.started_at
        end
        if s.terminated_at > latest_date
          latest_date = s.terminated_at
        end
      end

      wallet = 0.0
      consecutive_count = 0
      (earliest_date..latest_date).each do |day|
        if @ap.get_adherence_status_on(day) == AdherencePresenter::ADHERE_YES
          consecutive_count = consecutive_count + 1
        else
          consecutive_count = 0
        end
        if consecutive_count == @reward_rule.num_of_days
          wallet = wallet + @reward_rule.reward
          consecutive_count = 0
        end
      end
      # Then, substract the amoung of money paid.
      self.wallet_transactions.each do |wt|
        wallet = wallet - wt.amount
      end

      self.wallet_balance = wallet
      self.save
    end

  private

  # Internal: Create a unique 6 digits mist id
  #
  # Returns nothing.
  def create_mist_id
    self.mist_id = "#{id.to_s.rjust(5, '0').rjust(6, '1')}"
    self.save
  end

  def encrypt(string)
    public_key_file = 'public.pem'
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_file))
    encrypted_string = Base64.encode64(public_key.public_encrypt(string))
    return encrypted_string
  end

  def decrypt(encrypted_string)
    private_key_file = 'private.pem'
    password = 'adminadmin'

    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_file),password)
    originalString = private_key.private_decrypt(Base64.decode64(encrypted_string))
    return originalString
  end

end
