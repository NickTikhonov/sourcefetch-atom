AnswerSelector = require '../lib/answer-selector'
Answer = require '../lib/answer'
AnswerSection = require '../lib/answer-section'

SAMPLE_URL_1 = "http://www.stackoverflow.com/questions/sample1"
SAMPLE_URL_2 = "http://www.stackoverflow.com/questions/sample2"
SAMPLE_URL_3 = "http://www.stackoverflow.com/questions/sample3"

describe "AnswerSelector", ->

  it "should find the correct number of answers", ->
    scraper =
      scrape: ->

    spyOn(scraper, 'scrape').andReturn new Promise (resolve, reject) ->
      resolve [
        new Answer("bob", 10, true, [new AnswerSection("text", "sample")])
        new Answer("bob", 10, true, [new AnswerSection("text", "sample")])
        new Answer("bob", 10, true, [new AnswerSection("text", "sample")])
      ]

    selector = new AnswerSelector(scraper)

    waitsForPromise ->
      selector.find([SAMPLE_URL_1], numAnswers: 2, minVotes: 5).then (answers) ->
        expect(answers).toEqual [
          new Answer("bob", 10, true, [new AnswerSection("text", "sample")])
          new Answer("bob", 10, true, [new AnswerSection("text", "sample")])
        ]

  it "should find answers by scraping multiple urls", ->
    scraper =
      scrape: ->

    spyOn(scraper, 'scrape').andCallFake (url) ->
      return new Promise (resolve, reject) ->
        resolve [
          [
            new Answer("bob", 10, true, [new AnswerSection("text", "answer1")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer2")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer3")])
          ],
          [
            new Answer("bob", 10, true, [new AnswerSection("text", "answer4")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer5")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer6")])
          ]
        ][scraper.scrape.callCount - 1]

    selector = new AnswerSelector(scraper)

    waitsForPromise ->
      selector.find([SAMPLE_URL_1, SAMPLE_URL_2], numAnswers: 4, minVotes: 5).then (answers) ->
        expect(answers).toEqual [
          new Answer("bob", 10, true, [new AnswerSection("text", "answer1")])
          new Answer("bob", 10, true, [new AnswerSection("text", "answer2")])
          new Answer("bob", 10, true, [new AnswerSection("text", "answer3")])
          new Answer("bob", 10, true, [new AnswerSection("text", "answer4")])
        ]

  it "should stop scraping when it found enough answers", ->
    scraper =
      scrape: ->

    spyOn(scraper, 'scrape').andCallFake (url) ->
      return new Promise (resolve, reject) ->
        resolve [
          [
            new Answer("bob", 10, true, [new AnswerSection("text", "answer1")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer2")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer3")])
          ],
          [
            new Answer("bob", 10, true, [new AnswerSection("text", "answer4")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer5")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer6")])
          ],
          [
            new Answer("bob", 10, true, [new AnswerSection("text", "answer7")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer8")])
            new Answer("bob", 10, true, [new AnswerSection("text", "answer9")])
          ]
        ][scraper.scrape.callCount - 1]

    selector = new AnswerSelector(scraper)

    waitsForPromise ->
      selector.find([SAMPLE_URL_1, SAMPLE_URL_2, SAMPLE_URL_3], numAnswers: 4, minVotes: 5).then (answers) ->
        expect(scraper.scrape.callCount).toBe(2)


  it "should sort answers by the number of votes", ->
    scraper =
      scrape: ->

    spyOn(scraper, 'scrape').andReturn new Promise (resolve, reject) ->
      resolve [
        new Answer("bob", 1, true, [new AnswerSection("text", "answer1")])
        new Answer("bob", 7, true, [new AnswerSection("text", "answer2")])
        new Answer("bob", 5, true, [new AnswerSection("text", "answer3")])
      ]

    selector = new AnswerSelector(scraper)

    waitsForPromise ->
      selector.find([SAMPLE_URL_1], numAnswers: 3, minVotes: 5).then (answers) ->
        expect(answers).toEqual [
          new Answer("bob", 7, true, [new AnswerSection("text", "answer2")])
          new Answer("bob", 5, true, [new AnswerSection("text", "answer3")])
          new Answer("bob", 1, true, [new AnswerSection("text", "answer1")])
        ]

  it "should ignore unnacepted answers with few enough votes", ->
    scraper =
      scrape: ->

    spyOn(scraper, 'scrape').andReturn new Promise (resolve, reject) ->
      resolve [
        new Answer("bob", 1, true, [new AnswerSection("text", "answer1")])
        new Answer("bob", 9, false, [new AnswerSection("text", "answer2")])
        new Answer("bob", 9, false, [new AnswerSection("text", "answer3")])
        new Answer("bob", 9, true, [new AnswerSection("text", "answer3")])
        new Answer("bob", 5, false, [new AnswerSection("text", "answer3")])
      ]

    selector = new AnswerSelector(scraper)

    waitsForPromise ->
      selector.find([SAMPLE_URL_1], numAnswers: 4, minVotes: 6).then (answers) ->
        expect(answers).toEqual [
          new Answer("bob", 9, false, [new AnswerSection("text", "answer2")])
          new Answer("bob", 9, false, [new AnswerSection("text", "answer3")])
          new Answer("bob", 9, true, [new AnswerSection("text", "answer3")])
          new Answer("bob", 1, true, [new AnswerSection("text", "answer1")])
        ]
