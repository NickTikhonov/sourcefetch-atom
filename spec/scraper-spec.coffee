Scraper   = require '../lib/scraper'
fs        = require 'fs'
path      = require 'path'

describe "scrabing empty html", ->
  it "returns empty list when there are no answers", ->
    scraper = new Scraper()
    expect(scraper.scrape('<html></html>').answers).toEqual([])

describe "scraping a page with one accepted answer", ->
  scraper = new Scraper()
  testHtml = undefined

  it "returns the 3 parts of the answer", ->
    testHtml = undefined
    scraper = new Scraper()

    fs.readFile path.resolve(__dirname, 'so-one-accepted.html'), (err, body) ->
      testHtml = body

    waitsFor ->
      testHtml

    runs ->
      snippets = scraper.scrape(testHtml)
      snippet = snippets.answers[0]
      expect(snippet.answers).toBeDefined()
      expect(snippet.answers.length).toBe(3)

  it "returns the correct metadata", ->
    testHtml = undefined
    scraper = new Scraper()

    fs.readFile path.resolve(__dirname, 'so-one-accepted.html'), (err, body) ->
      testHtml = body

    waitsFor ->
      testHtml

    runs ->
      snippets = scraper.scrape(testHtml)
      snippet = snippets.answers[0]
      expect(snippet.author).toBe("Yuriko")
      expect(snippet.votes).toBe(3)
      expect(snippet.accepted).toBe(true)

  it "returns the correct question text", ->
    testHtml = undefined
    scraper = new Scraper()

    fs.readFile path.resolve(__dirname, 'so-one-accepted.html'), (err, body) ->
      testHtml = body

    waitsFor ->
      testHtml

    runs ->
      scraped = scraper.scrape(testHtml)
      expect(scraped.question).toBe("Error in compiling hello world in c")
