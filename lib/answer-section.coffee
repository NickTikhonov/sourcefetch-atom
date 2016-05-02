class AnswerSection
  constructor: (@type, @body) ->
    if @type not in ["text", "code"]
      throw new Error("Illegal type")
    else if @body is ""
      throw new Error("Illegal body size")

  isText: -> @type is "text"
  isCode: -> @type is "code"

module.exports = AnswerSection
