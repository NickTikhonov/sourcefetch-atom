SourcefetchView = require './sourcefetch-view'
{CompositeDisposable} = require 'atom'

module.exports = Sourcefetch =
  sourcefetchView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @sourcefetchView = new SourcefetchView(state.sourcefetchViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @sourcefetchView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'sourcefetch:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @sourcefetchView.destroy()

  serialize: ->
    sourcefetchViewState: @sourcefetchView.serialize()

  toggle: ->
    console.log 'Sourcefetch was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
