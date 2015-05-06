path = require 'path'
util = require 'util'
request = require 'superagent'
FeedParser = require 'feedparser'
moment = require 'moment'
EventProxy = require 'eventproxy'
fetchAll = require './fetch/fetchAll'
doUpdate = require './fetch/doUpdate'
tools = require './msg_tool'
persistenceFactory = require './persistence'

moment.locale 'zh_cn'

rssWorker = {}
rssWorker.lastUpdate = null
rssWorker.inited = false
rssWorker.hasTimeout = false

rssWorker.start = (opt) ->
#参数检查
  if !util.isArray opt.urls || opt.urls.length == 0
    throw new Error '【rss-worker】urls必须为数组，且长度不能为0'
  if opt.store.type == undefined || opt.store.type != 'mongo'
    opt.store.type = 'fs'
    opt.store.dist = path.join __dirname, '../store/rss.txt'
  if opt.store.type == 'fs'
    opt.store.dist = path.normalize opt.store.dist

  persistence = persistenceFactory.get opt.store.type

  this.fetchAll opt.urls, persistence, opt.store.dist

rssWorker.fetchAll = (urls, persistence, dist) ->
  ep = new EventProxy()
  ep.after 'fetch_done', urls.length, (resultArr) ->
    _formatted = tools.formatMsgToString resultArr

    if rssWorker.inited == false
      rssWorker.inited = true
      persistence.save dist, _formatted.content
      console.log "首次写入完毕！"
    else if _formatted.isUpdate
      persistence.update dist, _formatted.content
      console.log "更新完毕！"
    else
      console.log "无更新，结束"

    #防止并行任务组发生重叠
    setTimeout rssWorker.fetchAll, 1000 * 10, urls, persistence, dist

  for url in urls
    rssWorker.fetchOne url, ep

rssWorker.fetchOne = (url, ep) ->
  timeStart = moment()
  _fetchResult = []
  feedParser = new FeedParser()
  req = request.get url
  req.pipe feedParser

  feedParser.on 'error', (err) ->
    console.error err

  feedParser.on 'readable', () ->
    steam = this
    if not rssWorker.inited
      fetchAll steam, _fetchResult, rssWorker
    else
      doUpdate steam, _fetchResult, rssWorker

  feedParser.on 'end', () ->
    console.log "【rss-worker】<#{url}> 完成了一次爬取，爬取的内容条数为#{_fetchResult.length}，从#{timeStart.format 'YYYY年MMMMDoa h:mm:ss'} 到 #{moment().format 'YYYY年MMMMDoa h:mm:ss'},花费了#{(moment() - timeStart) / 1000}秒"
    if _fetchResult.length != 0
      _fetchResult.isUpdate = true
    ep.emit 'fetch_done', _fetchResult

module.exports = rssWorker
