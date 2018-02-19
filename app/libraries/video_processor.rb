class VideoProcessor

  attr_accessor :path, :video

  def initialize(video)
    @path = File.dirname(video)
    @video = video
  end

  # merge audio to video
  def merge(audio)
    merge = Ffmpeg.new :merge
    merge.input = [@video, audio]
    merge.output = filepath("#{Time.zone.now.to_i}.mp4")

    File.delete(merge.dest_file) if File.exist? merge.dest_file

    merge.execute
    merge
  end

  # rotate video clockwise by 90 degrees
  def rotate
    rotate = Ffmpeg.new :rotate
    rotate.input = @video
    rotate.output = filepath("#{Time.zone.now.to_i}.mp4")

    File.delete(rotate.dest_file) if File.exist? rotate.dest_file

    rotate.execute
    rotate
  end

  def swap
    convert = Ffmpeg.new :convertYUV
    convert.input = @video
    convert.output = filepath("#{Time.zone.now.to_i}.yuv")
    convert.execute
    if File.exist?(convert.outputs.last)
      swap = Ffmpeg.new :swap
      swap.input = convert.outputs.last
      swap.output = filepath"#{Time.zone.now.to_i}_swapped.mp4"

      File.delete(swap.dest_file) if File.exist? swap.dest_file

      swap.execute
      swap
    end
    if swap
      File.delete(convert.dest_file) if File.exist? convert.dest_file
    end
    swap
  end

  private

  def filepath(name)
    File.join(@path, name)
  end
end
