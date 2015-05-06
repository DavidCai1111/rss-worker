path = require 'path'
should = require 'should'
mongoose = require 'mongoose'
rssWorker = require '../index'
Msg = require '../lib/persistence/mongo/model'

describe 'test rss-worker', () ->
  this.timeout 1000 * 60

  it 'test mongodb', (done) ->
    before () ->
      mongoose.connect 'mongodb://localhost:27017/rss_worker', () ->
        Msg.remove {}
    after () ->
      Msg.remove {}

    opt =
      urls: ['https://github.com/DavidCai1993.atom', 'https://github.com/alsotang.atom']
      store:
        type: 'mongodb'
        dist: 'mongodb://localhost:27017/rss_worker'
      timeout: 5
    rssWorker.start opt

    validation = () ->
      Msg.find {}, (err, msgs) ->
        if err
          throw new Error err
        console.log "length : #{msgs.length}"
        msgs.should.have.length 60
        done()

    setTimeout validation, 10 * 1000