class MissingRecordChecker

  # Public: mark the next record time as missed if it exceeds
  #         the max delay time or a next record is due
  #
  # Returns nothing
  def self.mark_missed_record(patient)
    return unless patient.current_schedule


    time ||= Time.zone.now


    to_time = proc { |d| lambda { |t| Ptime.to_time(t, d) } }
    # select pill time candidates from within periods
    candidates =
        patient.current_schedule.pill_times_from(:yesterday).map(&to_time.call(time.yesterday)) +
        patient.current_schedule.pill_times_from(:today).map(&to_time.call(time)) +
        patient.current_schedule.pill_times_from(:tomorrow).map(&to_time.call(time.tomorrow))


    if candidates.length == 0

          return nil 

    elsif  candidates.length == 1


          if time >= candidates.last + 12.hour


              records = patient.records.pill_time(candidates.last)

              if records.length == 0


                return create_missing_record patient, candidates.last, 'allowed pill time is expired'


              end


          end 


    else 


        candidates.each_with_index {|val, index| 


          if index < candidates.length - 1 then 

            next_val = candidates[index+1]


            if time > val + (next_val - val) / 2


              records = patient.records.pill_time(val)

              if records.length == 0

                  return create_missing_record patient, val, 'allowed pill time is expired'

              end 

               

            end 


          else


              if time >= candidates.last + 12.hour


                records = patient.records.pill_time(candidates.last)


                if records.length == 0

                   return create_missing_record patient, candidates.last, 'allowed pill time is expired'

                end 

          

            end 



          end 
             
          

        }


  end

end 

  private

  # create a missing record
  def self.create_missing_record(patient, time, reason)
    return unless time

    patient.records.create device: 'MIST System',
      pill_time_at: time,
      received: false,
      report: 2, 
      graded: false, 
      meta: "Missed #{Ptime.to_human_readable(time)} pill because #{reason}."
  end

end
