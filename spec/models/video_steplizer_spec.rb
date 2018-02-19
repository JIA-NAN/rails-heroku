require 'spec_helper'

describe VideoSteplizer do
  let(:steplizer) { VideoSteplizer.new 'test/a.mp4', 'b.mp4', [1.3, 4.5, 7.8, 9.2, 13.8] }

  it '#execute' do
    expect(steplizer).to receive(:verify_steps).once.and_return(true)
    expect(steplizer).to receive(:convert_video).once.and_return(true)
    expect(steplizer).to receive(:split_video).once.and_return(true)
    expect(steplizer).to receive(:adjust_video_speed).once.and_return(true)
    expect(steplizer).to receive(:concat_videos).once.and_return(true)
    expect(steplizer).to receive(:cleanup_path).once.and_return(true)

    steplizer.execute

    expect(steplizer.succeed?).to be_true
  end

  it '#verify_steps' do
    Ffmpeg.stub(length: 15.0)
    expect(steplizer.verify_steps).to be_true
  end

  it '#step_meta' do
    # default empty
    expect(steplizer.step_meta).to eq('')
    # assign some outputs
    steplizer.step_outputs << 2.0 << 3.0 << 1.0 << 4.0 << 5.0
    expect(steplizer.step_meta).to eq('2.0,5.0,6.0,10.0,15.0')
  end
end
