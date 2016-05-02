AnswerSection = require '../lib/answer-section'
Answer= require '../lib/answer'

describe "Answer", ->
  it "can have code", ->
    sections = []
    sections.push new AnswerSection("text", "This is how you print hello world")
    sections.push new AnswerSection("code", "print 'hello'")
    answer = new Answer("Bob", 30, true, sections)

    expect(answer.hasCode()).toBe(true)

  it "can have no code", ->
    sections = []
    sections.push new AnswerSection("text", "The first text section")
    sections.push new AnswerSection("text", "The second text section")
    answer = new Answer("Bob", 30, true, sections)

    expect(answer.hasCode()).toBe(false)
