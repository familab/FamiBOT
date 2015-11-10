# Description:
#   Help decide between two things
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot flip a coin - Gives you heads or tails
#	hubot pick <option 1> <option 2> - Hubot picks one for you.
#
# Author:
#   Studs

thecoin = ["heads", "tails"]

module.exports = (robot) ->
  robot.respond /(coinflip|flip a coin)/i, (msg) ->
    msg.reply msg.random thecoin

module.exports = (robot) ->
  robot.respond /^pick\s*(\w+)\s+(\w+)/ig, (msg) ->
    options = [
      msg.match[1]
      msg.match[2]
    ]
    msg.reply msg.random options