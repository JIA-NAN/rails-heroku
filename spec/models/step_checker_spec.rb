require 'spec_helper'

describe StepChecker do
  before :each do
    @video = double()
    @checker = StepChecker.new @video, [9.207, 10.583, 17.167, 25.36, 30.302], 5
  end

  it 'should #analyze valid' do
    @checker.stub(video_length: 28)
    expect(@checker.valid?).to be_true
  end

  it 'should #size? invalid' do
    @checker.steps_num = 6
    expect(@checker.size?).to be_false
  end

  it 'should spaced? invalid' do
    @checker.timestamps = [2.0, 4.0, 6.0, 8.0, 9.9]
    expect(@checker.spaced?).to be_false
  end

  it 'should bounded? invalid' do
    @checker.stub(video_length: 23)
    expect(@checker.bounded?).to be_false
  end
end
