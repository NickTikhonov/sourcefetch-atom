{CompositeDisposable} = require 'atom'

getSnippet = (soLink) ->
  return new Promise (resolve, reject) ->
    request = require 'request'
    request soLink, (error, response, body) ->
      if !error && response.statusCode == 200
        cheerio = require 'cheerio'
        $ = cheerio.load body
        resolve $('div.accepted-answer code').text()
      else
        console.log error
        reject reason: 'Problem scraping StackOverflow'

searchGoogle = (query, language) ->
  return new Promise (resolve, reject) ->
    google = require "google"
    google.resultsPerPage = 1

    searchString = "#{query} in #{language} site:stackoverflow.com"
    google searchString, (err, next, links) ->
      if err
        reject reason: "An error has occured"

      if links.length == 0
        console.log "No results"
        reject reason: "No results were found"

      soLink = links[0].link
      resolve soLink

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'sourcefetch:fetch': => @fetch()

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
      .then (soLink) ->
        atom.notifications.addSuccess "Googled problem."
        getSnippet(soLink)
        .then (snippet) ->
          atom.notifications.addSuccess "Got snippet!"
          editor.insertText(snippet)
        , (err) ->
          atom.notifications.addError err.reason
      , (err) ->
        atom.notifications.addError err.reason
