fs = require 'fs-extra'
path = require 'path'

module.exports = (filePath, content) ->
  fileDir = path.dirname filePath
  tmpFilePath = path.join fileDir, '/tmp.txt'

  fs.ensureFileSync filePath
  fs.ensureFileSync tmpFilePath
  oldMsg = fs.readFileSync filePath
  fs.appendFileSync tmpFilePath, content
  fs.appendFileSync tmpFilePath, oldMsg
  fs.removeSync filePath
  fs.rename tmpFilePath, filePath