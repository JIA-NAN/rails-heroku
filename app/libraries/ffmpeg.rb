class Ffmpeg

  FFMPEG = ENV['FFMPEG'] || 'ffmpeg'

  #========================================
  # Supported Tasks:
  #   :convert, :merge, :rotate, :concat, :split, :speed
  #========================================

  attr_accessor :cmd, :inputs, :outputs, :succeed,
                :dest_path, :dest_prefix, :dest_ext, :options

  def initialize(cmd, options = {}, &block)
    @cmd = cmd
    @inputs = []
    @outputs = []
    @options = options

    instance_eval(&block) if block_given?
  end

  def input(*files)
    @inputs += files
    @outputs = []
  end

  def input=(file)
    @inputs = file.respond_to?(:each) ? file : [file]
    @outputs = []
  end

  def output(*args)
    if (args.size == 1)
      file = args[0]

      @dest_path   = File.dirname(file)
      @dest_ext    = File.extname(file)
      @dest_prefix = File.basename(file, @dest_ext)
    else
      path, ext, prefix = args

      @dest_path   = path
      @dest_ext    = ext
      @dest_prefix = prefix || ""
    end
  end

  def output=(file)
    @dest_path   = File.dirname(file)
    @dest_ext    = File.extname(file)
    @dest_prefix = File.basename(file, @dest_ext)
  end

  def dest_file(postfix = nil, ext = @dest_ext)
    File.join(@dest_path, "#{@dest_prefix}_#{@cmd}#{postfix}#{ext}")
  end

  def execute(*args)
    cmds = send("build_#{@cmd}_cmd", *args)

    if cmds.nil?
      @succeed = true
    elsif cmds.respond_to? :each
      cmds.each do |cmd|
        @succeed = system(cmd, err: dest_file("_err", ".log"))
        return false if !succeed?
      end
    else
      @succeed = system(cmds, err: dest_file("_err", ".log"))
    end

    @succeed
  end

  def succeed?
    @succeed == true
  end

  # get length of a video
  def self.length(video)
    if File.exist? video
      duration = %x[#{FFMPEG} -i "#{video}" 2>&1 | grep "Duration"]

      if duration[/([0-9]{2}):([0-9]{2}):([0-9]{2}\.[0-9]{2})/]
        $1.to_i * 3600 + $2.to_i * 60 + $3.to_f
      else
        0.0
      end
    else
      nil
    end
  end

  private

  def input_files
    @inputs.map { |i| "-i \"#{i}\"" }.join(" ")
  end

  # convert to i frames
  def build_convert_cmd
    outputs << dest_file
    "#{FFMPEG} #{input_files} -qscale 0 -intra \"#{outputs.last}\""
  end

  # merge audio + video
  def build_merge_cmd
    outputs << dest_file
    "#{FFMPEG} #{input_files} \"#{outputs.last}\""
  end

  # rotate video
  def build_rotate_cmd
    outputs << dest_file

    transpose = case options[:rotation]
                # 0 = 90CounterCLockwise and Vertical Flip (default)
                when :cclockwise90v then 0
                # 1 = 90Clockwise
                when :clockwise90 then 1
                # 2 = 90CounterClockwise
                when :cclockwise90 then 2
                # 3 = 90Clockwise and Vertical Flip
                when :clockwise90v then 3
                # default = 90Clockwise
                else 1
                end

    "#{FFMPEG} #{input_files} -vf \"transpose=#{transpose}\" \"#{outputs.last}\""
  end

  # swap the u,v value of video (for android mobile phone)
  def build_convertYUV_cmd
    outputs  << dest_file
    "#{FFMPEG} #{input_files} #{outputs.last}"
  end

  def build_swap_cmd
    outputs << dest_file
    #for small phone, it's 320*240, but sometimes could be bigger. let's see.
    "#{FFMPEG} -s 320x240 #{input_files} -filter swapuv #{outputs.last} "
  end

  # concat videos together
  def build_concat_cmd
    outputs << dest_file

    if options[:demuxer]
      tmp_concat_file = dest_file("_tcc", ".txt")

      File.open(tmp_concat_file, "w") do |file|
        inputs.each { |i| file.write("file '#{File.basename(i)}'\n") }
      end

      "#{FFMPEG} -f concat -i \"#{tmp_concat_file}\" -c copy \"#{outputs.last}\""
    else
      "#{FFMPEG} -i \"concat:#{@inputs.join('|')}\" -c copy \"#{outputs.last}\""
    end
  end

  # split video at time points
  def build_split_cmd(split_points)
    cmds = []

    split_points.inject(0) do |prev, cur|
      duration = cur.ceil - prev
      outputs << dest_file("_part#{cmds.count}")
      cmds    << "-an -vcodec copy "\
                 "-ss #{format_time(prev)} -t #{format_time(duration)} "\
                 "\"#{outputs.last}\""
      cur.ceil
    end

    "#{FFMPEG} #{input_files} #{cmds.join(' ')}"
  end

  # speed times +ve: speedup, -ve: slowdown
  def build_speed_cmd(times)
    video_opt = "setpts=#{(1.0 / times)}*PTS"
    new_fps   = calculate_new_fps(times) if options[:update_frames]

    @outputs << dest_file

    if options[:no_audio]
      "#{FFMPEG} #{input_files} #{new_fps} -filter:v"\
      " \"#{video_opt}\" \"#{@outputs.last}\""
    else
      audio_opt = calculate_audio_times(times)

      "#{FFMPEG} #{input_files} #{new_fps} -filter_complex"\
      " \"[0:v]#{video_opt}[v];[0:a]#{audio_opt}[a]\""\
      " -map \"[v]\" -map \"[a]\" \"#{@outputs.last}\""
    end
  end

  def calculate_new_fps(times)
    if options[:new_fps]
      "-r #{options[:new_fps]}"
    else
      "-r #{(options[:fps] || 10) * times}" if times > 1
    end
  end

  def calculate_audio_times(times)
    return "atempo=#{times}" if times >= 0.5 && times <= 2.0

    atimes    = times > 2.0 ? 2.0 : 0.5
    result    = "atempo=#{atimes}"
    times     = times / atimes
    acumulate = 0

    while (atimes == 2.0 && times > 1.0) || (atimes == 0.5 && times < 1.0)
      atmepo  = [0.5, [2.0, times].min].max
      result += ";atempo=#{atmepo}"
      times   = times / atimes

      break if (acumulate += 1) > 5 # only acumulate 5 times
    end

    result
  end

  def format_time(time)
    hour = rjust_time_component(time / 3600)
    min  = rjust_time_component((time % 3600) / 60)
    sec  = rjust_time_component((time % 60))

    "#{hour}:#{min}:#{sec}"
  end

  def rjust_time_component(t)
    t.to_s.rjust(2, "0")
  end

end
