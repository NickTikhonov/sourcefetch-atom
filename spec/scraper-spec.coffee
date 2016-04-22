Scraper   = require '../lib/scraper'
fs        = require 'fs'
path      = require 'path'

describe "scraping stackoverflow pages", ->
  it "returns empty list when there are no answers", ->
    scraper = new Scraper()
    expect(scraper.scrape('<html></html>')).toEqual([])

  it "returns single accepted answer", (done) ->
    testHtml = undefined
    scraper = new Scraper()

    fs.readFile path.resolve(__dirname, 'so-one-accepted.html'), (err, body) ->
      testHtml = body

    waitsFor ->
      testHtml

    runs ->
      snippets = scraper.scrape(testHtml)
      expect(snippets.length).toBe(1)

      firstSnippet = snippets[0]
      expect(firstSnippet.accepted).toBe(true)
      expect(firstSnippet.code).toMatch("include")
