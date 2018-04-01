# Description
#   Monitor Hubot's Slack connection
#
#

Slack = require './lib/slack.coffee'

module.exports = (robot) ->
  robot.adapter.client.on 'raw_message', (raw_message) ->
    if raw_message == '{"type": "hello"}'
      robot.logger.info 'Lost slack connection: restarting'
      setTimeout () ->
        process.exit 0
      ,   500
      slack.send_msg { room: 'C1N0S0AAD' }, 'famibot lost slack connection and has been automatically restarted'
      