path = require 'path'
fs = require 'fs-extra'
moment = require 'moment'

#获取所有内容，用于第一次获取
#
#@参数steam ：输入流
#@参数result_arr ： 储存结果的数组
#@参数ctx ： 上下文
module.exports = (steam, result_arr, ctx) ->
  item
  while item = steam.read()
    _lastUpdate = item.date

    if ctx.lastUpdate == null
      ctx.lastUpdate = _lastUpdate

    #确保是并行任务中的最后更新时间
    if ctx.lastUpdate < _lastUpdate
      ctx.lastUpdate = _lastUpdate

    _msg =
      date: moment item.date
      content: "#{moment(item.date).format 'YYYY年MMMMDoa h:mm:ss'}\n#{item.title}\n#{item.description}\n\n"
    result_arr.push _msg
