# Public: check a video on whether it follows the actions
#         specified in steps
class ActionChecker

  attr_reader :video, :steps

  def initialize(video, steps, opts = {})
    @video, @steps = video, steps
  end

  def valid?
  end

end
