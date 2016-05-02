class AnswerSelector
  constructor: (@scraper) ->
    console.log "Constructed."

  find: (urls, {numAnswers, minVotes}) ->
    console.log "find called"
    self = this
    return new Promise (resolve, reject) ->
      foundAnswers = []
      findAnswersRecursive = ->
        if urls.length is 0
          if foundAnswers.length is 0
            reject reason: "Couldn't find any relevant answers"
          else
            resolve foundAnswers
        else
          currentLink = urls.shift()
          self.scraper.scrape(currentLink).then (newAnswers) ->
            foundAnswers = foundAnswers.concat self.__filter(newAnswers, minVotes)
            if foundAnswers.length >= numAnswers
              resolve foundAnswers
            else
              findAnswersRecursive()
          .catch (err) ->
            findAnswersRecursive()

      findAnswersRecursive()

  __filter: (answers, minVotes) ->
    answers.filter (answer) -> answer.accepted or answer.votes > minVotes

module.exports = AnswerSelector
