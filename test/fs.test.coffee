path = require 'path'
http = require 'http'
should = require 'should'
fs = require 'fs-extra'
RssWorker = require '../index'

count = 0

describe 'test rss-worker', () ->
  this.timeout 1000 * 60

  before () ->
    fs.removeSync path.join __dirname, '/store'
    http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      if count == 0
        rss = fs.readFileSync path.join __dirname,'./rss_test/before.xml'
        count += 1
      else
        rss = fs.readFileSync path.join __dirname,'./rss_test/after.xml'
      res.end rss
    .listen 3788, '127.0.0.1'

  after () ->
    fs.removeSync path.join __dirname, '/store'

  it 'test fs', (done) ->
    _path = path.join __dirname, '/store/rss.txt'
    opt =
      urls: ['http://127.0.0.1:3788']
      store:
        type: 'fs'
        dist: _path
      timeout: 5

    rss_worker = new RssWorker opt
    rss_worker.start()

    validation = () ->
      rss_worker.forceToEnd()
      fs.ensureFileSync _path
      _text = fs.readFileSync(_path).toString()
      _text.should.containEql 'DavidCai1993 starred tjworks/docs'
      done()

    setTimeout validation, 15 * 1000

