# Public: check the timestamps of the video steps:
#         - within the video length
#         - have a minimum gap among time
class StepChecker

  attr_accessor :video, :timestamps, :steps_num

  # Public: initialize
  #
  # video - video file
  # timestamps - an array the steps timestamps
  # steps_num - number of steps required
  #
  def initialize(video, timestamps, steps_num, opts = {})
    @video, @timestamps, @steps_num = video, timestamps, steps_num
  end

  def valid?
    size? && spaced? && bounded?
  end

  # Public: validate steps has same size as sequence steps
  #
  # Returns true if size match.
  def size?
    @timestamps.size == @steps_num
  end

  # Public: validate video's length has at least 10 seconds
  #         otherwise, it is likely a error submission
  #
  # Returns true if length > 10s.
  def length?
    video_length > 10.0
  end

  # Public: validates gaps among timestamps have at least 2 seconds
  #
  # Returns true if spaced?
  def spaced?
    sum = 0.0

    @timestamps.inject(0) do |prev, cur|
      sum += cur - prev
      cur
    end

    (sum / @timestamps.size) >= 2.0
  end

  # Public: validates timestamps do not exceeds the video's length
  #
  # Returns true if within length
  def bounded?
    @timestamps[-2] + 2.0 <= video_length
  end

  private

  def video_length
    @video_length ||= Ffmpeg.length(@video)
  end
end
