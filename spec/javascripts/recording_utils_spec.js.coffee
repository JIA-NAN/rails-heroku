#= require spec_helper
#= require recording/utils

describe "Recording Utils", ->
  describe "toggleBtn", ->
    beforeEach ->
      @btn = $("<a>Text</a>")

    it "should be defined", ->
      expect(toggleBtn).to.be.defined

    it "should change button state", ->
      expect(@btn.prop("disabled")).to.be.undefined
      toggleBtn(@btn, false)
      expect(@btn.prop("disabled")).to.be.true
      toggleBtn(@btn, true)
      expect(@btn.prop("disabled")).to.be.false

    it "should change button text", ->
      toggleBtn(@btn, true, null)
      expect(@btn.html()).to.equal("Text")
      toggleBtn(@btn, true, "Hello")
      expect(@btn.html()).to.equal("Hello")

    it "should hide button", ->
      toggleBtn(@btn, true, null, true)
      expect(@btn.hasClass("hidden")).to.be.true
