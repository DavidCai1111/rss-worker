fs = require 'fs-extra'

module.exports = (path, content) ->
  outputContent = ""
  outputContent += msg for msg in content
  fs.ensureFileSync path
  fs.appendFileSync path, outputContent