# Description:
#   Slack library to format attachments and send messages back to Slack
#
class Slack
  constructor: (@robot)->

  send_msg: (envelope, message) ->
    # Check to see if bot was DM'd (room will start with D)
    # if it was set the room to the user's id so bot can DM back
    if envelope.room.charAt(0) == 'D'
      envelope.room = envelope.user.id

    @robot.adapter.send envelope,
      message

  reaction: (msg, emoji, text) ->
    if msg
      queryData = {
        token: process.env.HUBOT_SLACK_TOKEN
        name: emoji
        channel: msg.message.room
        timestamp: msg.message.id
      }

      @robot.http("https://slack.com/api/reactions.add")
        .query(queryData)
        .post() (err, res, body) ->
          console.log res.statusCode, body

  thread: (msg, text) ->
    @robot.adapter.send msg.envelope,
      id: 1,
      type: 'message',
      text: text,
      thread_ts: msg.message.id

  attachment: (envelope, title, message, colour) ->
    if envelope.room.charAt(0) == 'D'
      envelope.room = envelope.user.id

    @robot.adapter.send envelope,
      username: @robot.name,
      icon_url: 'https://avatars.slack-edge.com/2016-11-15/105034607940_a13c8717b8d42fed2cfb_48.jpg',
      attachments: [
        title: title,
        text: message,
        color: colour
      ]

  fields: (envelope, title, fields, colour) ->
    if envelope.room.charAt(0) == 'D'
      envelope.room = envelope.user.id

    field_list = []
    for k,v of fields
      field = {}
      text = ''
      field.title = k
      v.forEach (item) ->
        text = text + item
      field.value = text
      field.short = false
      field_list. push field

     @robot.adapter.send envelope,
      username: @robot.name,
      icon_url: 'https://avatars.slack-edge.com/2016-11-15/105034607940_a13c8717b8d42fed2cfb_48.jpg',
      attachments: [
        title: title,
        fields: field_list,
        color: colour
      ]

module.exports =
  Slack