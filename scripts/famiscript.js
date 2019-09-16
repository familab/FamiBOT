module.exports = (robot) => {
  robot.hear(/badger/i), res => {
    res.send("Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS");
  } 

  robot.respond(/open the pod bay doors/i), res =>
    res.reply("I'm afraid I can't let you do that.");

  robot.hear(/I like pie/i), res => {
    res.emote("makes a freshly baked pie");
  }
   

  robot.hear(/^(.*) [is|are] awesome/i), res => {
    res.send("I think #{res.match[1]} is awesome too");
  }

  // logging
  // robot.listenerMiddleware((context, next, done) => {
  //   // Log commands
  //   robot.logger.info("#{context.response.message.user.name} asked me to #{context.response.message.text}");
  //   // Continue executing middleware
  //   next()
  // })
}
