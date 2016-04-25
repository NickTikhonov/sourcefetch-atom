cheerio = require 'cheerio'
request = require 'request'

class Scraper

  # Downloads URL to SO page
  # and calls scrapeHTML to scrape it
  scrapeURL: (soLink) ->
    self = this
    return new Promise (resolve, reject) ->
      request soLink, (error, response, body) ->
        if not error and response.statusCode is 200
          snippet = self.scrapeHTML body
          if snippet == []
            reject "No top answer"
          else
            resolve snippet
        else
          reject reason: 'Problem scraping StackOverflow'

  # Scrapes the HTML (as a string)
  # and produces a list of snippets
  scrapeHTML: (body) ->
    $ = cheerio.load body
    answers = []
    self = this

    $('div.answer').each (i, elem) ->
      answers.push self.scrapeAnswer(elem)

    return {
      question: $('#question-header .question-hyperlink').text().trim()
      answers: answers
    }

  # Extracts information about a single
  # answer from the HTML element "div.answer"
  # that contains it.
  scrapeAnswer: (elem) ->
    answerSections = []
    $ = cheerio.load elem
    $('.post-text').children().each (i, child) ->
      if child.tagName == "pre"
        answerSections.push {
          type: "code",
          body: $(child).text()
        }
      else if child.tagName == "p"
        answerSections.push {
          type: "text",
          body: $(child).text()
        }

    return {
      sections: answerSections
      author: $('.user-details a').text().trim()
      votes: parseInt $('.vote-count-post').text(), 10
      accepted: $('span.vote-accepted-on').length == 1
    }

module.exports = Scraper
