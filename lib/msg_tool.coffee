msg_tool = {}

#formatMsgToString
#
#@参数result_arr ：所有并行的爬虫任务所获取的结果数组
#@返回 ：格式化好并排序好的结果字符串
msg_tool.formatMsgToString = (result_arr) ->
  _output = [];
  _stringResult =
    content: []
    isUpdate: false

  for msg_arr in result_arr
    if msg_arr.isUpdate == true then _stringResult.isUpdate = true

    for _item in msg_arr
      _output.push _item

  _output.sort (msg1, msg2) ->
    if msg1.date < msg2.date
      return 1
    else if msg1.date > msg2.date
      return -1
    else
      return 0

  for _rss in _output
    _stringResult.content.push _rss.content

  _stringResult

module.exports = msg_tool