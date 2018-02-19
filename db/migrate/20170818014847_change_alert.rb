class ChangeAlert < ActiveRecord::Migration
  def change
    add_column :alerts, :minute_before_pill_time, :integer, default: 15
    add_column :alerts, :message_before_pill_time, :string, default: 'Your medication is due in 15 minutes'
    add_column :alerts, :message_on_pill_time, :string,  default: 'It is now time to take your medication'
    add_column :alerts, :minute_after_pill_time, :integer, default: 30
    add_column :alerts, :message_after_pill_time, :string , default: 'Your medication time has passed. Please take your medication as soon as possible!'
    add_column :alerts, :day_full_adherence, :integer, default: 7
    add_column :alerts, :message_full_adherence, :string , default: 'It is now time to take your medication'
    add_column :alerts, :day_full_adherence2, :integer, default: 14
    add_column :alerts, :number_time_missing_pill, :integer, default: 1
  end
end
