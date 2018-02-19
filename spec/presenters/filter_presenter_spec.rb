require 'spec_helper'

describe FilterPresenter do
  it 'should append default to filters' do
    presenter = FilterPresenter.new([2, 3], 1)
    expect(presenter.filters).to eq([1, 2, 3])
  end

  it 'should not append if default in filters' do
    presenter = FilterPresenter.new([1, 2, 3], 1)
    expect(presenter.filters).to eq([1, 2, 3])
  end

  it 'should get current' do
    presenter = FilterPresenter.new([2, 3], 1)
    presenter.current = 3
    expect(presenter.active).to eq(3)
  end

  it 'should get default if current not in list' do
    presenter = FilterPresenter.new([2, 3], 1)
    presenter.current = 5
    expect(presenter.active).to eq(1)
  end
end
