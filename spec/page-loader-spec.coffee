PageLoader = require('../lib/page-loader')
loader = new PageLoader()

describe "PageLoader", ->
  it "can download stackoverflow pages", ->
    url = "http://stackoverflow.com/questions/32473272/meteor-query-for-all-documents-with-unique-field"
    waitsForPromise ->
      loader.get(url).then (body) ->
        expect(typeof body).toEqual("string")

  it "cannot download non-stackoverflow pages", ->
    url = "http://www.google.com"
    waitsForPromise ->
      loader.get(url).catch (err) ->
        expect(err.reason).toEqual("Illegal URL")
