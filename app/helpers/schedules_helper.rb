module SchedulesHelper

  def format_time(time)
    if time.nil?
      "0900"
    else
      time < 1000 ? "0#{time}" : "#{time}"
    end
  end

end
