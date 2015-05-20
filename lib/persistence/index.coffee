mongoose = require 'mongoose'
fs_save = require './fs/save'
fs_update = require './fs/update'
mongo_save = require './mongo/save'
mongo_update = require './mongo/update'

fs = {}
fs.save = fs_save
fs.update = fs_update

mongodb = {}
mongodb.save = mongo_save
mongodb.update = mongo_update

factory = {}
factory.get = (type, url) ->
  if type == 'fs'
    return fs
  else if type == 'mongodb'
    mongoose.connect url
    return mongodb
  else
    throw new Error '【rss-worker】选择的存储方式必须为fs或mongodb'

module.exports = factory