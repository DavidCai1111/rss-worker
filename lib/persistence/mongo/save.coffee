Msg = require './model'
EventProxy = require 'eventproxy'

module.exports = (path, content) ->
  ep = new EventProxy()
  ep.after 'save', content.length, (msgs) ->
    msgs

  for msg in content
    Msg.create {msg: msg}, (err, msg) ->
      if err
        throw new Error err
      ep.emit 'save', msg