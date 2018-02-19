# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
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
#  firstname              :string(255)
#  lastname               :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :firstname, :lastname,
                  :role_ids, :remember_me,
                  :password, :password_confirmation

  validates :firstname, :lastname, presence: true
  validates :email, uniqueness: true

  has_many :grades
  has_and_belongs_to_many :roles

  # paginate
  self.per_page = 30

  # notification ids
  alias_attribute :email_id, :email

  def fullname
    "#{firstname.capitalize}, #{lastname.upcase}"
  end
end
