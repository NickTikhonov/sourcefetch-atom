{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'sourcefetch:fetch': => @fetch()

  deactivate: ->
    @subscriptions.dispose()

  fetch: ->
    console.log 'Sourcefetch was toggled!'
