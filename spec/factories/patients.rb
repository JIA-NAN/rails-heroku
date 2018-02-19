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

FactoryGirl.define do
  factory :patient do
	mist_id '100001'
    firstname 'John'
    lastname 'Tan'
    password '12345678'
    sequence(:email) { |i| "firstname_#{i}@fyp.com" }
    sequence(:phone) { |i| "+65#{i.to_s.rjust(8, '0')}" }
  end
end
