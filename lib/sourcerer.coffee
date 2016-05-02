{CompositeDisposable} = require 'atom'

SearchEngine  = require './search'
PageLoader = require './page-loader'
Scraper = require './scraper'
AnswerSelector = require './answer-selector'
ResultView = require './results-view'

search = new SearchEngine()
loader = new PageLoader()
scraper = new Scraper(loader)
selector = new AnswerSelector(scraper)

module.exports =
  subscriptions: null

  config:
    minVotes:
      title: "Minimum Number of Votes"
      description: "The number of votes needed by an unaccepted answer to appear in the results."
      type: 'integer'
      default: 50
      minimum: 1
    numAnswers:
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

    language = editor.getGrammar().name
    query = editor.getSelectedText()
    if query.length == 0
      atom.notifications.addWarning "Please make a valid selection"
      return

    search.searchGoogle query, language
    .then (soLinks) ->
      atom.notifications.addSuccess "Googled problem."
      console.log selector
      return selector.find soLinks,
        numAnswers: atom.config.get('sourcerer.numAnswers')
        minVotes: atom.config.get('sourcerer.minVotes')
    .then (answers) ->
      if atom.config.get('sourcerer.luckyMode')
        best = bestAnswer answers
        best.insertWith editor,
          insertDescription: atom.config.get('sourcerer.insertDescription'),
          credit: true
      else
        new ResultView(editor, answers)
    .catch displayErrorNotification

# -- end of module.exports --

bestAnswer = (answers) ->
  answers.reduce (p, v) ->
    if p.votes > v.votes then p else v

displayErrorNotification = (err) ->
  atom.notifications.addError err.reason
