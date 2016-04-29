google = require 'google'
google.resultsPerPage = 10

class Search
  buildSearchString: (query, language) ->
    query = query.toLowerCase().trim()
    "#{query} in #{language} site:stackoverflow.com"

  searchGoogle: (query, language) ->
    self = this
    return new Promise (resolve, reject) ->
      searchQuery = self.buildSearchString(query, language)
      google searchQuery, (err, res) ->
        if err
          reject reason: "Google Error - are you online?"
        else if res.links.length == 0
          reject reason: "No results were found"
        else
          resolve res.links.map (item) -> item.link

module.exports = Search
