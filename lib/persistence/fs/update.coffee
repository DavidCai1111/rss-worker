fs = require 'fs-extra'
path = require 'path'

module.exports = (filePath, content) ->
  outputContent = ""
  outputContent += msg for msg in content

  fileDir = path.dirname filePath
  tmpFilePath = path.join fileDir, '/tmp.txt'

  fs.ensureFileSync filePath
  fs.ensureFileSync tmpFilePath
  oldMsg = fs.readFileSync filePath
  fs.appendFileSync tmpFilePath, outputContent
  fs.appendFileSync tmpFilePath, oldMsg
  fs.removeSync filePath
  fs.rename tmpFilePath, filePath