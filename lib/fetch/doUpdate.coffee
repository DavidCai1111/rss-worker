path = require 'path'
fs = require 'fs-extra'
moment = require 'moment'

#用于检查并更新RSS
#
#@参数steam ：输入流
#@参数resultArr ： 储存结果的数组
module.exports = (steam, resultArr) ->
  while item = steam.read()
    hasUpdate = true
    _lastUpdate = item.date

    #若有更新则抓取，否则结束
    if @lastUpdate < _lastUpdate
      @lastUpdate = _lastUpdate
      hasUpdate = true
      console.log "【rss-worker】检测到更新"
    else
      hasUpdate = false

    if hasUpdate
      msg =
        date: moment item.date
        content: "#{moment(item.date).format 'YYYY年MMMMDoa h:mm:ss'}\n#{item.title}\n#{item.description}\n\n"
      resultArr.push msg
      console.log '【rss-worker】完成更新！'
    else
      return