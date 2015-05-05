fs = require 'fs-extra'

exports = (steam)->
  while item = steam.read()
    msg = "#{item.title}\n#{item.description}\n\n"
    fs.appendFileSync (path.join __dirname, '../store/rss.txt'), msg
