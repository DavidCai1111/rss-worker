fs = require 'fs-extra'
path = require 'path'

module.exports = (filePath, content) ->
  _content = ""
  for msg in content
    _content += msg

  fileDir = path.dirname filePath
  tmpFilePath = path.join fileDir, '/tmp.txt'

  fs.ensureFileSync filePath
  fs.ensureFileSync tmpFilePath
  oldMsg = fs.readFileSync filePath
  fs.appendFileSync tmpFilePath, _content
  fs.appendFileSync tmpFilePath, oldMsg
  fs.removeSync filePath
  fs.rename tmpFilePath, filePath