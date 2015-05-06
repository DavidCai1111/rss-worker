fs = require 'fs-extra'

module.exports = (path, content) ->
  _content = ""
  for msg in content
    _content += msg
  fs.ensureFileSync path
  fs.appendFileSync path, _content