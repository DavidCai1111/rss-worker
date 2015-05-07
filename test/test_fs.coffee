path = require 'path'
should = require 'should'
fs = require 'fs-extra'
RssWorker = require '../index'

describe 'test rss-worker', () ->
  this.timeout 1000 * 60


  it 'test fs', (done) ->
    before () ->
      fs.removeSync path.join __dirname, '/store'
    after () ->
      fs.removeSync path.join __dirname, '/store'

    _path = path.join __dirname, '/store/rss.txt'
    opt =
      urls: ['https://github.com/DavidCai1993.atom', 'https://github.com/alsotang.atom']
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

    setTimeout validation, 10 * 1000

