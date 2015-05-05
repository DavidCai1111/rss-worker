path = require 'path'
fs = require 'fs-extra'

module.exports = (steam, optPath)->
  item
  while item = steam.read()
    msg = "#{item.title}\n#{item.description}\n\n"
    fs.ensureFileSync optPath
    fs.appendFileSync optPath, msg
