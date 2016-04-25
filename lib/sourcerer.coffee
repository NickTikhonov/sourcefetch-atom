{CompositeDisposable} = require 'atom'
{insertAnswer} = require './editor-utils'
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
      scraper.scrapeURL(currentLink).then (result) ->
        results = results.concat filterAnswers(result.answers)
        if results.length >= atom.config.get('sourcerer.numSnippets')
          resolve results
        else
          findSnippetsRecursive()
      , (err) ->
        findSnippetsRecursive()

    findSnippetsRecursive()

filterAnswers = (answers) ->
  answers.filter (answer) ->
    answer.accepted || answer.votes > atom.config.get('sourcerer.notAcceptedRequiredVotes')

bestAnswer = (answers) ->
  answers.reduce (p, v) ->
    if p.votes > v.votes then p else v

module.exports =
  subscriptions: null
  config:
    notAcceptedRequiredVotes:
      title: "Minimum Number of Votes"
      description: "The number of votes needed by an unaccepted answer to appear in the results."
      type: 'integer'
      default: 50
      minimum: 1
    numSnippets:
      title: "Minimum number of snippets"
      description: "Number of snippets fetched by Sourcerer per query"
      type: 'integer'
      default: 3
      minimum: 1
    luckyMode:
      title: "I'm feeling lucky"
      description: "Do not show the preview window, automatically insert the best snippet found based on the number of votes"
      type: 'boolean'
      default: false
    insertDescription:
      title: "Insert accompanying text"
      description: "Insert the accompanying StackOverflow answer text as well as the code"
      type: 'boolean'
      default: true

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'sourcerer:fetch': => @fetch()

  deactivate: ->
    @subscriptions.dispose()

  fetch: ->
    return unless editor = atom.workspace.getActiveTextEditor()
    selection = editor.getSelectedText()

    if selection.length == 0
      atom.notifications.addWarning "Please make a valid selection"
      return

    language = editor.getGrammar().name
    search.searchGoogle(selection, language).then (soLinks) ->
      atom.notifications.addSuccess "Googled problem."
      findSnippets(soLinks).then (snippets) ->
        if atom.config.get('sourcerer.luckyMode')
          best = bestAnswer snippets
          insertAnswer editor, best
        else
          new ResultView(editor, snippets)
        # editor.insertText(snippet)
      , (err) ->
        console.log err
        atom.notifications.addError err.reason
    , (err) ->
      console.log err
      atom.notifications.addError err.reason
