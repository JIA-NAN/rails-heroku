# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
#
# Learn more: http://github.com/javan/whenever

set :output, "#{ENV['EB_CONFIG_APP_LOGS']}/cron_log.log"

# push notifications to patients
every 5.minutes do
  runner "WheneverTask.push_notify_pill_times"
end

# push scheduled push notifications to patients
every 15.minutes do
  runner "WheneverTask.push_notify_scheduled"
end

# check missed pill records
every 30.minutes do
  runner "WheneverTask.mark_missed_records"
end

# run delayed jobs
every :day, at: "2:30 am" do
  rake "jobs:workoff"
end
