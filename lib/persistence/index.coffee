mongoose = require 'mongoose'
fs_save = require './fs/save'
fs_update = require './fs/update'
mongo_save = require './mongo/save'
mongo_update = require './mongo/update'

fs =
  save: fs_save
  update: fs_update

mongodb =
  save: mongo_save,
  update: mongo_update

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