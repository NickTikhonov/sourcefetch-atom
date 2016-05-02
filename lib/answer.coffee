class Answer
  constructor: (@author, @votes, @accepted, @sections) ->

  hasCode: -> (@sections.filter (section) -> section.isCode()).length > 0

  insertWith: (editor, {insertDescription, credit}) ->
    if insertDescription
      @__insertComment editor, "~ Snippet by StackOverflow user #{@author} from an answer with #{@votes} votes. ~"

    for section in @sections
      if section.isCode()
        editor.insertText "\n" + section.body + "\n"
      else if section.isText()
        if insertDescription
          @__insertComment editor, section.body

  __insertComment: (editor, comment) ->
    editor.insertText comment + "\n", select: true
    selection = editor.getLastSelection()
    selection.toggleLineComments()
    selection.clear()

module.exports = Answer
