Scraper = require '../lib/scraper'
PageLoader = require '../lib/page-loader'
fs = require 'fs'
path = require 'path'

describe "Scraper", ->
  it "can first no answers", ->
    waitsForPromise ->
      mockLoader =
        get: (url) ->
          return new Promise (resolve, reject) ->
            resolve "<html></html>"

      scraper = new Scraper(mockLoader)
      scraper.scrape('someurl').then (answers) ->
        expect(answers).toEqual([])

  it "can find one answer", ->
    waitsForPromise ->
      mockLoader =
        get: (url) ->
          return new Promise (resolve, reject) ->
            fs.readFile path.resolve(__dirname, 'so-one-accepted.html'), (err, body) ->
              resolve body

      new Scraper(mockLoader).scrape('someurl').then (answers) ->
        expect(answers.length).toBe(1)

        first = answers[0]
        expect(first.author).toBe("Yuriko")
        expect(first.votes).toBe(3)
        expect(first.accepted).toBe(true)
        expect(first.sections.length).toBe(3)
        expect(first.sections[0].isText()).toBe(true)
        expect(first.sections[1].isCode()).toBe(true)
        expect(first.sections[2].isText()).toBe(true)
