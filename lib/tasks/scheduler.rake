desc "This task is called by the Heroku scheduler add-on"
task :push_notify_pill_times => :environment do
  

  WheneverTask.push_notify_pill_times


end

task :push_notify_scheduled => :environment do

  WheneverTask.push_notify_scheduled

end

task :mark_missed_records => :environment do

  WheneverTask.mark_missed_records
  
end