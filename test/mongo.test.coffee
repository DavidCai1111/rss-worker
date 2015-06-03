path = require 'path'
http = require 'http'
should = require 'should'
mongoose = require 'mongoose'
fs = require 'fs-extra'
RssWorker = require '../index'
Msg = require '../lib/persistence/mongo/model'

count = 0

describe 'test rss-worker', () ->
  this.timeout 1000 * 60

  before () ->
    http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/plain'}
      if count is 0
        rss = fs.readFileSync path.join __dirname,'./rss_test/before.xml'
        count += 1
      else
        rss = fs.readFileSync path.join __dirname,'./rss_test/after.xml'
      res.end rss
    .listen 3789, '127.0.0.1'


  after (done) ->
    Msg.remove {},() ->
      done()

  it 'test mongodb', (done) ->
    opt =
      urls: ['http://127.0.0.1:3789']
      store:
        type: 'mongodb'
        dist: 'mongodb://localhost:27017/rss_worker'
      timeout: 5

    test_mongo = () ->
      rss_worker = new RssWorker opt
      rss_worker.start()

      validation = () ->
        rss_worker.forceToEnd()
        Msg.find {}, (err, msgs) ->
          if err then throw new Error err
          console.log "length : #{msgs.length}"
          msgs.should.have.length 30
          done()

      setTimeout validation, 15 * 1000

    setTimeout test_mongo, 10 * 1000


