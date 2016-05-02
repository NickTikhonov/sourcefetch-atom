request = require "request"

class PageLoader
  # Downloads StackOverflow pages

  get: (url) ->
    allowedDomain = "http://www.stackoverflow.com/questions"
    return new Promise (resolve, reject) ->
      if url.indexOf allowedDomain is not -1
        request url, (error, response, body) ->
          if not error and response.statusCode is 200
            resolve body
          else
            reject reason: "Could not download the page"
      else
        reject reason: "Illegal URL"



module.exports = PageLoader
