path = require 'path'
fs = require 'fs-extra'
moment = require 'moment'

#获取所有内容，用于第一次获取
#
#@参数steam ：输入流
#@参数resultArr ： 储存结果的数组
module.exports = (steam, resultArr) ->
  while item = steam.read()
    _lastUpdate = item.date

    if @lastUpdate == null
      @lastUpdate = _lastUpdate

    #确保是并行任务中的最后更新时间
    if @lastUpdate < _lastUpdate
      @lastUpdate = _lastUpdate

    msg =
      date: moment item.date
      content: "#{moment(item.date).format 'YYYY年MMMMDoa h:mm:ss'}\n#{item.title}\n#{item.description}\n\n"
    resultArr.push msg