fs_save = require './fs/save'
fs_update = require './fs/update'

fs = {}
fs.save = fs_save
fs.update = fs_update

mongo = {}

factory = {}
factory.get = (type) ->
  if type == 'fs'
    return fs
  else if type == 'mongo'
    return mongo
  else
    throw new Error '【rss-worker】选择的存储方式必须为fs或mongo'

module.exports = factory