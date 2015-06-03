Msg = require './model'
EventProxy = require 'eventproxy'

module.exports = (path, content) ->
  ep = new EventProxy()
  ep.after 'update', content.length, (msgs) ->
    msgs

  for msg in content
    Msg.create {msg: msg}, (err, msg) ->
      if err then throw new Error err
      ep.emit 'update', msg