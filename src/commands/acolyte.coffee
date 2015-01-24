jsdom = require "jsdom"

module.exports = (robot, config) ->

  logger = robot.logger

  about = "I'm Acolyte, your personal Twitch robot. Calistar created me to assist you. For a complete list of commands please visit: http://twitch.tv/calistartv"

  # event: enter
  robot.enter (res) ->
    username = res.message.user.name
    channel = res.message.room.substring 1
    if robot.adapter.checkAccess username
      res.send "Greetings! #{about}"
    else if config.get("#{channel}.show_greet") is "on"
      res.send "Hello #{username}!"

  # command: #{robot.name}
  robot.hear new RegExp("/^#{robot.name}$/"), (res) ->
    res.reply "At your service."

  # command: !join
  robot.hear /^!join (.*)/, (res) ->
    current = res.message.room.substring 1
    channel = res.match[1]
    if robot.adapter.checkAccess(res.message.user.name) and current.toLowerCase() isnt channel.toLowerCase()
      robot.adapter.join "#" + channel
      res.reply "Joining #{channel}"

  # command: !leave
  robot.hear /^!leave (.*)/, (res) ->
    current = res.message.room.substring 1
    channel = res.match[1]
    if robot.adapter.checkAccess(res.message.user.name) and current.toLowerCase() isnt channel.toLowerCase()
      robot.adapter.part "#" + channel
      res.reply "Leaving #{channel}"

  # command: !config
  robot.hear /^!config ([\w_]+) (on|off|remove)/i, (res) ->
    channel = res.message.room.substring 1
    [key, value] = res.match.splice 1
    if res.message.user.name.toLowerCase() is channel.toLowerCase()
      unless value is "remove"
        robot.adapter.config.set "#{channel}.#{key}", value
        res.send "#{key} is now #{value}."
      else
        robot.adapter.config.remove "#{channel}.#{key}"
        res.send "#{key} removed."

  # about
  robot.hear /^!about/, (res) ->
    res.reply about