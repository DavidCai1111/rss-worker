path = require 'path'
request = require 'superagent'
FeedParser = require 'feedparser'
read = require 'node-readability'
fs = require 'fs-extra'
moment = require 'moment'
fetchAll = require './fetchAll'
doUpdate = require './doUpdate'

moment.locale 'zh_cn'

rssWorker = {}
#状态标记
rssWorker.lastUpdate = null
rssWorker.inited = false

rssWorker.start = (opt)->
  setInterval this.fetch, 1000 * 5

rssWorker.fetch = ()->
  timeStart = moment().format 'YYYY年MMMMDoa h:mm:ss'
  feedParser = new FeedParser()
  req = request.get 'https://github.com/DavidCai1993.atom'
  req.pipe feedParser

  feedParser.on 'error', (err)->
    console.error err

  feedParser.on 'readable', ()->
    steam = this
    if !rssWorker.inited
      fetchAll steam, (path.join __dirname, '../store/res.txt')
    else
      doUpdate steam, (path.join __dirname, '../store/res.txt'), rssWorker

  feedParser.on 'end', ()->
    rssWorker.inited = true
    console.log "【rss-worker】完成了一次爬取，从#{timeStart} 到 #{moment().format 'YYYY年MMMMDoa h:mm:ss'}"

module.exports = rssWorker
