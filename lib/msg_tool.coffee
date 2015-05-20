msg_tool = {}

#formatMsgToString
#
#@参数result_arr ：所有并行的爬虫任务所获取的结果数组
#@返回 ：格式化好并排序好的结果字符串
msg_tool.formatMsgToString = (resultArr) ->
  output = [];
  stringResult =
    content: []
    isUpdate: false

  for msgArr in resultArr
    if msgArr.isUpdate == true then stringResult.isUpdate = true

    for item in msgArr
      output.push item

  output.sort (msg1, msg2) ->
    if msg1.date < msg2.date
      return 1
    else if msg1.date > msg2.date
      return -1
    else
      return 0

  for rss in output
    stringResult.content.push rss.content

  stringResult

module.exports = msg_tool