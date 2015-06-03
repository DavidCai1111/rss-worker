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
    if not util.isArray @opt.urls or @opt.urls.length is 0 then throw new Error '【rss-worker】urls必须为数组，且长度不能为0'
    if @opt.timeout is undefined or typeof @opt.timeout isnt 'number' or @opt.timeout < 0 then @opt.timeout = 60 #默认为60秒间隔
    if @opt.store is undefined or (@opt.store.type isnt 'mongodb' and @opt.store.type isnt 'fs') then @opt.store = {type : 'fs', dist : path.join 'store/rss.txt'}
    if @opt.store.type is 'fs' then @opt.store.dist = path.normalize @opt.store.dist

    @persistence = persistenceFactory.get @opt.store.type, @opt.store.dist
    @feedParser = null
    @lastUpdate = null
    @inited = false
    @end = false

  start: () ->
    @fetchAll @opt.urls, @persistence, @opt.store.dist, @opt.timeout

  fetchAll: (urls, persistence, dist, timeout) ->
    console.log "【rss-worker】开始抓取！"
    ep = new EventProxy()
    ep.after 'fetch_done', urls.length, (resultArr) =>
      formatted = tools.formatMsgToString resultArr
      if @inited isnt true
        @inited = true
        @persistence.save dist, formatted.content
      else if formatted.isUpdate
        @persistence.update dist, formatted.content

      if not @end
        setTimeout @fetchAll.bind(@), 1000 * timeout, urls, persistence, dist, timeout
      else
        console.log "【rss-worker】结束抓取！"

    @fetchOne url, ep for url in urls

  fetchOne: (url, ep) ->
    timeStart = moment()
    fetchResult = []
    feedParser = new FeedParser()
    req = request.get url
    req.pipe feedParser

    feedParser.on 'error', (err) ->
      console.error err
      process.exit 0

    ctx = @
    feedParser.on 'readable', () ->
      steam = @
      if not ctx.inited
        fetch.call ctx, steam, fetchResult
      else
        doUpdate.call ctx, steam, fetchResult

    feedParser.on 'end', () ->
      console.log "【rss-worker】<#{url}> 完成了一次爬取，爬取的内容条数为#{fetchResult.length}，从#{timeStart.format 'YYYY年MMMMDoa h:mm:ss'} 到 #{moment().format 'YYYY年MMMMDoa h:mm:ss'},花费了#{(moment() - timeStart) / 1000}秒"
      if fetchResult.length isnt 0 then fetchResult.isUpdate = true
      ep.emit 'fetch_done', fetchResult

  forceToEnd: () ->
    @end = true

exports = module.exports = RssWorker
