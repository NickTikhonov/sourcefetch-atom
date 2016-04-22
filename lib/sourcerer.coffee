{CompositeDisposable} = require 'atom'

SearchEngine  = require './search'
Scraper = require './scraper'
ResultView = require './results-view'

search = new SearchEngine()
scraper = new Scraper()

# Returns the code from the first accepted SO answer
# from the provided URLs to SO pages.
findSnippets = (soLinks) ->
  return new Promise (resolve, reject) ->
    results = []

    findSnippetsRecursive = ->
      if soLinks.length == 0
        reject reason: "No accepted answers on StackOverflow"

      currentLink = soLinks.shift()
      console.log currentLink
      scraper.scrapeStackOverflow(currentLink).then (result) ->
        results.push result
        if results.length == 3
          resolve results
        else
          findSnippetsRecursive()
      , (err) ->
        findSnippetsRecursive()

    findSnippetsRecursive()

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
      search.searchGoogle(selection, language).then (soLinks) ->
        atom.notifications.addSuccess "Googled problem."
        findSnippets(soLinks).then (snippets) ->
          new ResultView(editor, snippets)
          # editor.insertText(snippet)
        , (err) ->
          atom.notifications.addError err.reason
      , (err) ->
        atom.notifications.addError err.reason
