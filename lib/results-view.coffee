{$$, SelectListView} = require 'atom-space-pen-views'

class ResultView extends SelectListView
  # items is a list of string code snippets
  initialize: (@editor, items) ->
    super
    @addClass('overlay from-top')
    @setItems(items)
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @focusFilterEditor()

  viewForItem: (item) ->
    $$ ->
      @li class: 'two-lines', =>
        @div "StackOverflow Snippet", class: 'primary-line'
        @div class: 'secondary-line', =>
          @pre item[0].code

  confirmed: (item) ->
    console.log("CONFIRMED")
    @cancel()
    @editor.insertText item[0].code

  cancelled: ->
    console.log("CANCELLED")
    @hide()

  hide: ->
    @panel?.hide()

module.exports = ResultView
