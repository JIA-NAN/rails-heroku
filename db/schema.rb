# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20170828013749) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true

  create_table "admins_roles", :id => false, :force => true do |t|
    t.integer "admin_id"
    t.integer "role_id"
  end

  add_index "admins_roles", ["admin_id", "role_id"], :name => "index_admins_roles_on_admin_id_and_role_id"

  create_table "alerts", :force => true do |t|
    t.integer  "time_start"
    t.integer  "time_repeat"
    t.string   "text"
    t.datetime "created_at",                                                                                                                :null => false
    t.datetime "updated_at",                                                                                                                :null => false
    t.integer  "minute_before_pill_time",  :default => 15
    t.string   "message_before_pill_time", :default => "Your medication is due in 15 minutes"
    t.string   "message_on_pill_time",     :default => "It is now time to take your medication"
    t.integer  "minute_after_pill_time",   :default => 30
    t.string   "message_after_pill_time",  :default => "Your medication time has passed. Please take your medication as soon as possible!"
    t.integer  "day_full_adherence",       :default => 7
    t.string   "message_full_adherence",   :default => "It is now time to take your medication"
    t.integer  "day_full_adherence2",      :default => 14
    t.integer  "number_time_missing_pill", :default => 1
  end

  create_table "applogs", :force => true do |t|
    t.string   "device"
    t.string   "version"
    t.string   "content"
    t.string   "level"
    t.string   "identifier"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "auto_grades", :force => true do |t|
    t.boolean  "is_face_recognized"
    t.float    "face_recognition_score"
    t.boolean  "is_pill_taken"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "record_id"
  end

  add_index "auto_grades", ["record_id"], :name => "index_auto_grades_on_record_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "grades", :force => true do |t|
    t.string   "grade"
    t.text     "comment"
    t.integer  "record_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "admin_id"
    t.text     "note"
    t.string   "pill_taken"
    t.string   "explanation"
  end

  add_index "grades", ["admin_id"], :name => "index_grades_on_admin_id"
  add_index "grades", ["record_id"], :name => "index_grades_on_record_id"

  create_table "medicines", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "medicines_pill_times", :id => false, :force => true do |t|
    t.integer "medicine_id"
    t.integer "pill_time_id"
  end

  add_index "medicines_pill_times", ["medicine_id", "pill_time_id"], :name => "index_medicines_pill_times_on_medicine_id_and_pill_time_id"

  create_table "notification_services", :force => true do |t|
    t.string   "name"
    t.string   "service"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "notification_subscriptions", :force => true do |t|
    t.integer  "patient_id"
    t.integer  "notification_service_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "notification_subscriptions", ["notification_service_id"], :name => "index_notification_subscriptions_on_notification_service_id"
  add_index "notification_subscriptions", ["patient_id"], :name => "index_notification_subscriptions_on_patient_id"

  create_table "notifications", :force => true do |t|
    t.string   "message"
    t.boolean  "sent",                    :default => false
    t.datetime "send_at"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "receiver"
    t.integer  "patient_id"
    t.integer  "notification_service_id"
  end

  add_index "notifications", ["notification_service_id"], :name => "index_notifications_on_notification_service_id"
  add_index "notifications", ["patient_id"], :name => "index_notifications_on_patient_id"

  create_table "patients", :force => true do |t|
    t.string   "firstname",                                                            :null => false
    t.string   "lastname",                                                             :null => false
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.string   "email",                                                :default => "", :null => false
    t.string   "encrypted_password",                                   :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.string   "mist_id",                                              :default => "", :null => false
    t.string   "phone"
    t.decimal  "wallet_balance",         :precision => 8, :scale => 2
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "patients", ["authentication_token"], :name => "index_patients_on_authentication_token", :unique => true
  add_index "patients", ["email"], :name => "index_patients_on_email", :unique => true
  add_index "patients", ["mist_id"], :name => "index_patients_on_mist_id"
  add_index "patients", ["reset_password_token"], :name => "index_patients_on_reset_password_token", :unique => true

  create_table "pill_sequence_steps", :force => true do |t|
    t.string   "name"
    t.integer  "step_no"
    t.string   "meta"
    t.integer  "pill_sequence_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "pill_sequence_steps", ["pill_sequence_id"], :name => "index_pill_sequence_steps_on_pill_sequence_id"

  create_table "pill_sequences", :force => true do |t|
    t.string   "name"
    t.boolean  "default",    :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "pill_times", :force => true do |t|
    t.integer  "monday"
    t.integer  "tuesday"
    t.integer  "wednesday"
    t.integer  "thursday"
    t.integer  "friday"
    t.integer  "saturday"
    t.integer  "sunday"
    t.integer  "schedule_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "pill_times", ["schedule_id"], :name => "index_pill_times_on_schedule_id"

  create_table "records", :force => true do |t|
    t.string   "device",                       :default => "unknown device"
    t.text     "comment"
    t.text     "status",                       :default => "pending"
    t.integer  "patient_id"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.string   "audio_file_name"
    t.string   "audio_content_type"
    t.integer  "audio_file_size"
    t.datetime "audio_updated_at"
    t.boolean  "video_processing"
    t.text     "meta"
    t.integer  "pill_sequence_id"
    t.text     "video_s3_file_name"
    t.string   "video_s3_content_type"
    t.integer  "video_s3_file_size"
    t.datetime "video_s3_updated_at"
    t.datetime "pill_time_at"
    t.string   "video_steplized_file_name"
    t.text     "video_steplized_content_type"
    t.text     "video_steplized_file_size"
    t.datetime "video_steplized_updated_at"
    t.text     "meta_steplized"
    t.boolean  "received"
    t.boolean  "graded"
    t.text     "screenshot_urls"
    t.datetime "actual_pill_time_at"
    t.integer  "report"
  end

  add_index "records", ["patient_id"], :name => "index_records_on_patient_id"
  add_index "records", ["pill_sequence_id"], :name => "index_records_on_pill_sequence_id"
  add_index "records", ["pill_time_at"], :name => "index_records_on_pill_time_at"

  create_table "records_side_effects", :id => false, :force => true do |t|
    t.integer "record_id"
    t.integer "side_effect_id"
  end

  add_index "records_side_effects", ["record_id", "side_effect_id"], :name => "index_records_side_effects_on_record_id_and_side_effect_id"

  create_table "reward_rules", :force => true do |t|
    t.integer  "num_of_days"
    t.decimal  "reward",      :precision => 8, :scale => 2
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",        :default => "User", :null => false
    t.text     "description"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "schedules", :force => true do |t|
    t.date     "started_at"
    t.date     "terminated_at"
    t.integer  "patient_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "schedules", ["patient_id"], :name => "index_schedules_on_patient_id"

  create_table "side_effects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "wallet_transactions", :force => true do |t|
    t.integer  "patient_id"
    t.decimal  "amount",     :precision => 8, :scale => 2
    t.datetime "time"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "wallet_transactions", ["patient_id"], :name => "index_wallet_transactions_on_patient_id"

  create_table "whenever_tasks", :force => true do |t|
    t.string   "task"
    t.string   "meta"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
