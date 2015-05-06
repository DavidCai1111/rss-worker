fs = require 'fs-extra'

module.exports = (path, content) ->
  fs.ensureFileSync path
  fs.appendFileSync path, content