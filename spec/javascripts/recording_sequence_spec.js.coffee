#= require spec_helper
#= require recording/utils
#= require recording/sequence

window.steps = ['step 1', 'step 2', 'step 3']

describe "Recording RecordSequence", ->
  #beforeEach ->
    #@$el = $("#recording-steps")
    #@$nextStep = $("#next-step-btn")

  it "should be defined", ->
    expect(recordSequence).to.be.defined

  it "should get initialized", ->
    recordSequence.init()

    expect(recordSequence.idx).to.equal(0)
    expect(recordSequence.timings).to.be.empty
    expect(recordSequence.started).to.be.false

    #expect(@$el.hasClass("hidden")).to.be.false
    #expect(@$el.html()).to.match(/prepare your pill and water/i)
    #expect(@$nextStep.html()).to.equal("Next Step")

  it "should get ready", ->
    recordSequence.ready()
    expect(recordSequence.started).to.be.true
