cheerio = require 'cheerio'
AnswerSection = require './answer-section'
Answer = require './answer'

class Scraper
  constructor: (@loader) ->

  scrape: (url) ->
    self = this
    return new Promise (resolve, reject) ->
      self.loader.get(url).then (body) ->
        $ = cheerio.load body

        answers = []
        $('div.answer').each (i, elem) ->
          answers.push self.__scrapeAnswer(elem)

        resolve answers
      .catch reject

  __scrapeAnswer: (elem) ->
    sections = []
    $ = cheerio.load elem
    $('.post-text').children().each (i, child) ->
      if child.tagName == "pre"
        sections.push new AnswerSection("code", $(child).text())
      else if child.tagName == "p"
        sections.push new AnswerSection("text", $(child).text())

    author = $('.user-details a').text().trim()
    votes = parseInt $('.vote-count-post').text(), 10
    accepted = $('span.vote-accepted-on').length == 1

    return new Answer(author, votes, accepted, sections)

module.exports = Scraper
