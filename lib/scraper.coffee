cheerio = require 'cheerio'
request = require 'request'

###
The Scraper class is responsible for downloading and extracting information
from StackOverflow pages. "scrapeURL" serves as the encompassing function
which produces a data object given a url. The object follows this structure:

{
  question: "<question string>"
  answers: [
    {
      author: "<author username>",
      votes: <number of votes>,
      accepted: <true|false>,
      sections: [{
        type: "<code|text>",
        body: "<string contents of the section>"
      }]
    }
  ]
}
###

class Scraper
  scrapeURL: (soLink) ->
    self = this
    return new Promise (resolve, reject) ->
      request soLink, (error, response, body) ->
        if not error and response.statusCode is 200
          pageInfo = self.scrapeHTML body
          resolve pageInfo
        else
          reject reason: 'Problem scraping StackOverflow'


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
  # answer from the "div.answer" HTML element.
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
