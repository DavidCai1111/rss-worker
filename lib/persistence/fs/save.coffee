fs = require 'fs-extra'

module.exports = (path, content) ->
  outputContent = ""
  for msg in content
    outputContent += msg
  fs.ensureFileSync path
  fs.appendFileSync path, outputContent