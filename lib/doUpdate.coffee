path = require 'path'
fs = require 'fs-extra'
moment = require 'moment'

module.exports = (steam, optPath, ctx)->
  item
  _hasUpdate = true
  while item = steam.read()
    _lastUpdate = moment item.date
    if ctx.lastUpdate == null
      ctx.lastUpdate = _lastUpdate
    #若有更新则抓取，否则结束
    if ctx.lastUpdate < _lastUpdate
      ctx.lastUpdate = _lastUpdate
      _hasUpdate = true
      console.log "【rss-worker】检测到更新！(#{_lastUpdate.format 'YYYY年MMMMDoa h:mm:ss'})"
    else
      _hasUpdate = false
    if _hasUpdate
      #使用临时文件完成头追加
      _msg = "#{item.title}\n#{item.description}\n\n"
      _optPathDir = path.dirname optPath
      _tmpFile = path.join _optPathDir, '/tmp.txt'
      fs.ensureFileSync optPath
      _oldMsg = fs.readFileSync optPath
      fs.appendFileSync _tmpFile, _msg
      fs.appendFileSync _tmpFile, _oldMsg
      fs.removeSync optPath
      fs.renameSync _tmpFile, optPath
      console.log '【rss-worker】完成更新！'
    else
      return