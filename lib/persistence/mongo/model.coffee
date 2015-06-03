mongoose = require 'mongoose'

MsgSchema = new mongoose.Schema {
  msg: String
}

module.exports = mongoose.model 'RssMsg', MsgSchema