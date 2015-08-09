# Description:
#   A script for creating and recalling dumbs from the chat using regular expressions and ID numbers
#
#   Example:
#     hubot !dumb Look at me! I'm on TV
#     hubot !dumb johnwyles: I really enjoy the band TV on the radio
#     hubot !dumbsearch *TV*
#       => Look at me! I'm on TV! [ID: 23]
#       => johnwyles: I really enjoy the band TV on the radio [ID: 24]
#     hubot !rmdumb 23
#       => Do you really want to purge the dumb [ID: 23] from the database?  Type 'rmdumb 23 seriously' if you are sure!
#     hubot !rmdumb 23 seriously
#       => The dumb has been removed from the database [ID: 23].
#     hubot !dumbsearch *TV*
#       => johnwyles: I really enjoy the band TV on the radio [ID: 24]
#     hubot !dumb
#       => Hello World!  This is a random dumb from the database! [ID: 832]
#     hubot !dumb 832
#       => Hello World!  This is a random dumb from the database! [ID: 832]
#     hubot !dumbsearch (F|f)oobar
#       => Foobar [ID: 56]
#       => foobar [ID: 57]
#       => Foobar is barfoo [ID: 58]
#       => There were [2] more dumbs found.  To retrieve all of these run again with dumball.  For example: 'dumball (F|f)oobar'.
#     hubot !dumbsearch (F|f)oobar
#       => Foobar [ID: 56]
#       => foobar [ID: 57]
#       => Foobar is barfoo [ID: 58]
#       => I once ate a foobar [ID: 61]
#       => Foobar FTW! [ID: 62]
#     hubot !purgealldumbs
#       => Do you really want to purge all of the dumbs in the database?  Type 'purgealldumbs seriously' if you are sure!
#     hubot !purgealldumbs seriously
#       => All dumbs have been purged from the database.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot !dumb <phrase or body of text>
#   hubot !rmdumb <dumb ID> [seriously]
#   hubot !randdumb [<dumb ID OR partial text OR regular expression>]
#   hubot !searchdumb <partial text OR regular expression>
#   hubot !purgealldumbs [seriously]
#
# Author:
#   johnwyles (although some of this is based on NNA's talkative.coffee)

module.exports = (robot) ->
  # The maximum number of dumbs output for a search
  maximum_dumbs_output = 3

  # This first dumb is made mostly unique so it doesn't interfere with the users DB
  # The reason this isn't a simple array and is instead an associative array is because
  # we want to preserve a dumbs unique id
  default_dumb_database = {
    "next_id": 1,
    "dumbs": [
      {"id": 0, "dumb": "Th1s1sy0urf1rstqu0te1nth3d4t4b4s3"}
    ],
    "rmdumb": [],
    "purgealldumbs": false
  }

  robot.brain.data.dumb_database or= default_dumb_database

  robot.respond /!dumb\s?(.*)?$/i, (msg) ->
    if msg.match[1]
      for dumb_index in robot.brain.data.dumb_database.dumbs
        if dumb_index.dumb == msg.match[1]
          msg.send "This dumb idea already exists [ID: #{dumb_index.id}]."
          return
      dumb_id = robot.brain.data.dumb_database.next_id++
      robot.brain.data.dumb_database.dumbs.push {"id": dumb_id, "dumb": msg.match[1]}
      msg.send "This message has been added [ID: #{dumb_id}]."
    else
      msg.send "You must supply some text after '!dumb'.  For example: '!dumb This will be added to the DB.'."

  robot.respond /!rmdumb\s?(\d+)?( seriously)?$/i, (msg) ->
    if msg.match[1]
      if not robot.brain.data.dumb_database.rmdumb[msg.match[1]] or not msg.match[2]
        msg.send "Do you really want to purge the dumb idea [ID: #{msg.match[1]}] from the database?  Type '!rmdumb #{msg.match[1]} seriously' if you are sure!"
        robot.brain.data.dumb_database.rmdumb[msg.match[1]] = true
        return

      if robot.brain.data.dumb_database.rmdumb[msg.match[1]] and msg.match[2]
        for dumb_index in robot.brain.data.dumb_database.dumbs
          if dumb_index.id is parseInt(msg.match[1])
            robot.brain.data.dumb_database.dumbs.splice robot.brain.data.dumb_database.dumbs.indexOf(dumb_index), 1
            msg.send "The dumb idea has been removed from the database [ID: #{dumb_index.id}]."
            robot.brain.data.dumb_database.rmdumb[msg.match[1]] = false
            return
        msg.send "The dumb idea specified could not be found [ID: #{msg.match[1]}]."
    else
      msg.send "You must supply a ID number after '!rmdumb'.  For example: 'rmdumb 123'."

  robot.respond /!randdumb\s?(?: (\d+)|\s(.*))?$/i, (msg) ->
    dumb_database = robot.brain.data.dumb_database

    # Find a random dumb
    if not msg.match[1] and not msg.match[2]
      random_dumb_index = Math.floor(Math.random() * dumb_database.dumbs.length)
      random_dumb = dumb_database.dumbs[random_dumb_index]
      msg.send "#{random_dumb.dumb} [ID: #{random_dumb.id}]"
      return

    # Find dumb by ID
    else if msg.match[1]
      for dumb_index in robot.brain.data.dumb_database.dumbs
        if dumb_index.id is parseInt(msg.match[1])
          msg.send "#{dumb_index.dumb} [ID: #{dumb_index.id}]"
          return
      msg.send "The dumb idea specified could not be found [ID: #{msg.match[1]}]."

    # Find dumb by pattern
    else if msg.match[2]
      dumb_found_count = 0
      for dumb_index in robot.brain.data.dumb_database.dumbs
        if dumb_index.dumb.match new RegExp(msg.match[2])
          dumb_found_count++
          if dumb_found_count <= maximum_dumbs_output
            msg.send "#{dumb_index.dumb} [ID: #{dumb_index.id}]"

        # robot.logging.info "Found: " + dumb_found_count + " Max: " + maximum_dumbs_output
      if dumb_found_count > maximum_dumbs_output
        excess_dumb_count = dumb_found_count - maximum_dumbs_output
        msg.send "There were [#{excess_dumb_count}] more dumb ideas found.  To retrieve all of these run again with !dumbsearch.  For example: '!dumbsearch (F|f)oobar'."
        return

      else if dumb_found_count < 1
        msg.send "There were no matching dumb ideas found [Pattern: #{msg.match[2]}]."

  robot.respond /!searchdumb\s?(.*)?$/i, (msg) ->
    # Find all dumbs by a pattern
    if msg.match[1]
      dumb_found = false
      for dumb_index in robot.brain.data.dumb_database.dumbs
        if dumb_index.dumb.match new RegExp(msg.match[1])
          dumb_found = true
          msg.send "#{dumb_index.dumb} [ID: #{dumb_index.id}]"

      if not dumb_found
        msg.send "There were no matching dumb ideas found [Pattern: #{msg.match[1]}]."

    else
      msg.send "You must supply a pattern to match after '!dumbsearch'.  For example: '!dumbsearch (F|f)oobar'."


  robot.respond /!purgealldumbs\s?( seriously)?$/i, (msg) ->
    if not robot.brain.data.dumb_database["purgealldumbs"] or not msg.match[1]
      msg.send "Do you really want to purge all of the dumb ideas in the database?  Type '!purgealldumbs seriously' if you are sure!"
      robot.brain.data.dumb_database["purgealldumbs"] = true
      return

    if msg.match[1] and robot.brain.data.dumb_database["purgealldumbs"]
      robot.brain.data.dumb_database = default_dumb_database
      msg.send "All dumb ideas have been purged from the database."
