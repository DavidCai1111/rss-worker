path = require 'path'
request = require 'superagent'
FeedParser = require 'feedparser'
read = require 'node-readability'
fs = require 'fs-extra'
moment = require 'moment'

moment.locale 'zh_cn'

rssWorker = {}

#状态标记
rssWorker.lastUpdate = null
rssWorker.inited = false

rssWorker.start = (opt)->
  setInterval this.fetch, 1000 * 8

rssWorker.fetch = ()->
  _hasUpdate = true
  timeStart = moment().format 'YYYY年MMMMDoa h:mm:ss'

  feedParser = new FeedParser()

  req = request.get 'https://github.com/DavidCai1993.atom'

  req.pipe feedParser

  feedParser.on 'error', (err)->
    console.error err

  feedParser.on 'readable', ()->
    steam = this
    item

    if !rssWorker.inited
      while item = steam.read()
        msg = "#{item.title}\n#{item.description}\n\n"
        fs.appendFileSync (path.join __dirname, '../store/rss.txt'), msg
    else

      while item = steam.read()
        _lastUpdate = moment item.date
        #初始化最新更新时间
        if rssWorker.lastUpdate == null
          rssWorker.lastUpdate = _lastUpdate
        #若有更新则抓取，否则结束
        if rssWorker.lastUpdate < _lastUpdate
          rssWorker.lastUpdate = _lastUpdate
          _hasUpdate = true
          console.log "检测到更新！#{_lastUpdate.format 'YYYY年MMMMDoa h:mm:ss'}"
        else
          _hasUpdate = false
        if _hasUpdate
          msg = "#{item.title}\n#{item.description}\n\n"
          #使用临时文件完成头追加
          oldMsg = fs.readFileSync path.join __dirname, '../store/rss.txt'
          fs.appendFileSync (path.join __dirname, '../store/tmp.txt'), msg
          fs.appendFileSync (path.join __dirname, '../store/tmp.txt'), oldMsg
          fs.remove path.join __dirname, '../store/rss.txt'
          fs.renameSync (path.join __dirname, '../store/tmp.txt'),(path.join __dirname, '../store/ress.txt')
          console.log '完成更新...'
        else
          return

  feedParser.on 'end', ()->
    rssWorker.inited = true
    console.log "结束，从#{timeStart} 到 #{moment().format 'YYYY年MMMMDoa h:mm:ss'}"

module.exports = rssWorker
