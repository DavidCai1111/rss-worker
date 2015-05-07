path = require 'path'
util = require 'util'
request = require 'superagent'
FeedParser = require 'feedparser'
moment = require 'moment'
EventProxy = require 'eventproxy'
fetch = require './fetch/fetchAll'
doUpdate = require './fetch/doUpdate'
tools = require './msg_tool'
persistenceFactory = require './persistence'

moment.locale 'zh_cn'

class RssWorker
  constructor: (@opt) ->
    this.feedParser = null
    this.lastUpdate = null
    this.inited = false
    this.end = false

  start: () ->
    if !util.isArray @opt.urls || @opt.urls.length == 0
      throw new Error '【rss-worker】urls必须为数组，且长度不能为0'
    if @opt.timedout == undefined || typeof @opt.timedout != 'number' || @opt.timedout < 0
      @opt.timedout = 5 #默认为5秒间隔
    if @opt.store == undefined || (@opt.store.type != 'mongodb' && @opt.store.type != 'fs')
      @opt.store = {}
      @opt.store.type = 'fs' #默认存储方式为fs
      @opt.store.dist = path.join 'store/rss.txt'

    if @opt.store.type == 'fs'
      @opt.store.dist = path.normalize @opt.store.dist

    persistence = persistenceFactory.get @opt.store.type, @opt.store.dist
    this.fetchAll @opt.urls, persistence, @opt.store.dist, @opt.timeout

  fetchAll: (urls, persistence, dist, timeout) ->
    ctx = this
    ep = new EventProxy()
    ep.after 'fetch_done', urls.length, (resultArr) ->
      _formatted = tools.formatMsgToString resultArr
      if ctx.inited == false
        ctx.inited = true
        persistence.save dist, _formatted.content
        console.log "【rss-worker】首次写入完毕！"
      else if _formatted.isUpdate
        persistence.update dist, _formatted.content
        console.log "【rss-worker】更新完毕！"
      else
        console.log "【rss-worker】无更新，结束"

      if not ctx.end
        #替代setInterval防止并行任务组发生重叠
        setTimeout ctx.fetchAll.bind(ctx), 1000 * timeout, urls, persistence, dist, timeout
      else
        console.log '结束！'

    for url in urls
      ctx.fetchOne url, ep

  fetchOne: (url, ep) ->
    ctx = this
    timeStart = moment()
    _fetchResult = []
    feedParser = new FeedParser()
    req = request.get url
    req.pipe feedParser

    feedParser.on 'error', (err) ->
      console.error err
      process.exit 0

    feedParser.on 'readable', () ->
      steam = this
      if not ctx.inited
        fetch steam, _fetchResult, ctx
      else
        doUpdate steam, _fetchResult, ctx

    feedParser.on 'end', () ->
      console.log "【rss-worker】<#{url}> 完成了一次爬取，爬取的内容条数为#{_fetchResult.length}，从#{timeStart.format 'YYYY年MMMMDoa h:mm:ss'} 到 #{moment().format 'YYYY年MMMMDoa h:mm:ss'},花费了#{(moment() - timeStart) / 1000}秒"
      if _fetchResult.length != 0
        _fetchResult.isUpdate = true
      ep.emit 'fetch_done', _fetchResult

  forceToEnd: () ->
    this.end = true


exports = module.exports = RssWorker
