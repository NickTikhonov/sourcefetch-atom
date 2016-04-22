cheerio = require 'cheerio'
request = require 'request'

class Scraper
  scrape: (body) ->
    $ = cheerio.load body
    snippet = $('div.accepted-answer pre code').text()
    if snippet is ""
      return []
    else
      return [{accepted: true, code: snippet}]

  scrapeStackOverflow: (soLink) ->
    self = this
    return new Promise (resolve, reject) ->
      request soLink, (error, response, body) ->
        if not error and response.statusCode is 200
          snippet = self.scrape body
          if snippet == []
            reject "No top answer"
          else
            resolve snippet
        else
          reject reason: 'Problem scraping StackOverflow'


module.exports = Scraper
