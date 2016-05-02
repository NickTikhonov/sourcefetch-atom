AnswerSection   = require '../lib/answer-section'

describe "AnswerSection", ->
  it "can be a code section", ->
    section = new AnswerSection("code", "print 'Hello World'\n")
    expect(section.isCode()).toBe(true)

  it "can be a text section", ->
    section = new AnswerSection("text", "Example text section")
    expect(section.isText()).toBe(true)

  it "cannot be an unsupported type", ->
    expect(-> new AnswerSection("invalid", "some value")).toThrow(new Error("Illegal type"));

  it "cannot have an empty body", ->
    expect(-> new AnswerSection("text", "")).toThrow(new Error("Illegal body size"))
