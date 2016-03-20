{CompositeDisposable} = require 'atom'
google = require 'google'
request = require 'request'
cheerio = require 'cheerio'

# Returns the code from the first accepted SO answer
# from the provided URLs to SO pages.
findSnippet = (soLinks) ->
  return new Promise (resolve, reject) ->
    if soLinks.length == 0
      reject reason: "No results found for this query."

    findSnippetRecursive = ->
      currentLink = soLinks.shift()
      console.log currentLink
      scrapeStackOverflow(currentLink).then (result) ->
        resolve result
      , (err) ->
        if soLinks.length == 0
          reject reason: "No accepted answers on StackOverflow"
        else
          findSnippetRecursive()

    findSnippetRecursive()

# Extracts the accepted answer code from
# a StackOverflow page
scrapeStackOverflow = (soLink) ->
  return new Promise (resolve, reject) ->
    request soLink, (error, response, body) ->
      if !error && response.statusCode == 200
        $ = cheerio.load body
        snippet = $('div.accepted-answer pre code').text()
        console.log snippet
        if snippet == ""
          votes = $('span.vote-count-post').first().text()
          snippet = $('div.answer pre code').first().text()
          console.log votes
          console.log snippet
          if parseInt( votes, 10 ) < 0
            reject reason: "Badly voted answer, not a good idea"

          else
            atom.notifications.addWarning("This was not a top voted answer, but
            the best we could get with #{votes} votes")
            resolve snippet
          if snippet == ""
            reject reason: 'No accepted answer / no code in accepted answer'
        else
          resolve snippet
      else
        reject reason: 'Problem scraping StackOverflow'


# Returns a list of StackOverlow links
# for the given query and language
searchGoogle = (query, language) ->
  return new Promise (resolve, reject) ->
    google.resultsPerPage = 10

    searchString = "#{query} in #{language} site:stackoverflow.com"
    console.log "SEARCHING: #{searchString}"
    google searchString, (err, res) ->
      if err
        reject reason: "An error has occured"

      if res.links.length == 0
        reject reason: "No results were found"

      soLinks = res.links.map (item) -> item.link
      resolve soLinks


module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'sourcerer:fetch': => @fetch()


  deactivate: ->
    @subscriptions.dispose()

  fetch: ->
    if editor = atom.workspace.getActiveTextEditor()
      selection = editor.getSelectedText()

      if selection.length == 0
        atom.notifications.addWarning "Please make a valid selection"
        return

      language = editor.getGrammar().name

      searchGoogle(selection, language)
      .then (soLinks) ->
        atom.notifications.addSuccess "Googled problem."
        findSnippet(soLinks)
        .then (snippet) ->
          atom.notifications.addSuccess "Got snippet!"
          editor.insertText(snippet)
        , (err) ->
          atom.notifications.addError err.reason
      , (err) ->
        atom.notifications.addError err.reason
