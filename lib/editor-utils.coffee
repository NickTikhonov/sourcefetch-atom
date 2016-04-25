insertComment = (editor, comment) ->
  editor.insertText comment + "\n", select: true
  selection = editor.getLastSelection()
  selection.toggleLineComments()
  selection.clear()

insertAnswer = (editor, answer) ->
  insertComment editor, "~ Snippet by StackOverflow user #{answer.author} from an answer with #{answer.votes} votes. ~"
  for section in answer.sections
    if section.type == "code"
      editor.insertText "\n" + section.body + "\n"
    else if section.type == "text"
      if atom.config.get('sourcerer.insertDescription')
        insertComment editor, section.body

module.exports =
  insertComment: insertComment,
  insertAnswer: insertAnswer
