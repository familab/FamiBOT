
/* eslint-disable no-unused-expressions */
/* eslint-disable strict */
const uuidv1 = require('uuid/v1');
const redis = require('redis');
const decode = require('decode-html');

const redisUrl = process.env.REDISTOGO_URL || 'redis://127.0.0.1:6379';
const client = redis.createClient(redisUrl);

const badger = [
  'Badgers? Honey badgers are the best',
  'I love honey badgers',
  'badger badger badger snek! Snek!',
  'Capt Badger reporting for snek!',
  'Honey badgers are my fav',
  `Honey badger! Not only is its skin tough, it's loose enough that a honey badger can turn around in it and bite its 
   attacker. And speaking of bites, the honey badger can survive the bites of some very dangerous creatures. 
   They eat scorpions and snakes, and they have an unusually strong immunity to venom.`,
  'Honey badgers get their name from their penchant for raiding beehives',
  `Honey Badgers have many reasons to be fearless. They have very thick (about 1/4 inches), rubbery skin, 
   which is so tough that it's been shown to be nearly impervious to traditionally made arrows and spears`,
  'Badgers!, they are great.',
  `While the American badger is an aggressive animal with few natural enemies it is still vulnerable to other species
   in its habitat. Badgers are hostile. Predation on smaller individuals by golden eagles (Aquila chrysaetos), coyotes,
   cougars (Puma concolor), and bobcats (Lynx rufus) have been reported`,
  'honey badgers can live to 24',
  `The Mustelidae (/ˌmʌˈstɛlɪdi/; from Latin mustela, weasel) are a family of carnivorous mammals, including weasels, 
   BADGERS, otters, ferrets, martens, minks, and wolverines, among others. Mustelids (/ˈmʌstəlɪd/) are a diverse group
   and form the largest family in the order Carnivora, suborder Caniformia`,
  `The honey badger (Mellivora capensis), also known as the ratel (/ˈreɪtəl/ or /ˈrɑːtəl/), is a mammal widely
   distributed in Africa, Southwest Asia, and the Indian subcontinent. The Guniess book of awesome defines them as
   completely the most awesome critter ever to terrorize everything. They are wicked.`,
  'badgers? Why always badgers? I love them, but really?'
];

function isInt(value) {
  if (isNaN(value)) {
    return false;
  }
  const x = parseFloat(value);
  // eslint-disable-next-line no-bitwise
  return (x | 0) === x;
}

module.exports = (robot) => {
  // badger badger badger
  robot.hear(/badger/i, (msg) => {
    const rand = Math.round(Math.random() * 600000);
    const totalBadgers = robot.brain.get('totalBadgers') + 1;
    robot.brain.set('totalBadgers', totalBadgers);
    setTimeout(() => {
      msg.send(msg.random(badger));
    }, rand);
    const user = msg.message.user;
    robot.logger.info(`${user.name} was heard saying ${msg.message.text} for the ${totalBadgers} time`);
  });

  robot.hear(/how many badgers\?/i, (msg) => {
    const totalBadgers = robot.brain.get('totalBadgers');
    msg.send(`The total number of badger messages is ${totalBadgers}`);
    const user = msg.message.user;
    robot.logger.info(`${user.name} was heard saying ${msg.message.text} for the ${totalBadgers} time`);
  });

  // agree with awesome
  robot.hear(/^(.*) (is|are|seems) awesome/i, (msg) => {
    const rand = Math.round((Math.random() * 60000) + 60000);
    const user = msg.message.user;
    setTimeout(() => {
      msg.send(`After careful consideration, I think that ${msg.match[1]} ${msg.match[2]} awesome too`);
    }, rand);
    robot.logger.info(`${user.name} was heard saying ${msg.message.text}`);
  });

  robot.hear(/^catbomb (\d+)$/i, (msg) => {
    const user = msg.message.user;
    let number = msg.match[1];
    if (isInt(number)) {
      if (number > 9) {
        number = 9;
        msg.send('Catbombs are limited to 10 at a time. Enjoy');
      }

      for (let i = 0; i < number; i++) {
        const rand = Math.round(Math.random() * 30000);
        setTimeout(() => {
          msg.send(`https://cataas.com/cat/gif?${uuidv1()}`);
        }, rand);
      }
      robot.logger.info(`${user.name} catbombed ${msg.message.text}`);
    } else {
      msg.say('naughty!');
      robot.logger.info(`${user.name} catbombed a non-number ${number}`);
    }
  });

  robot.hear(/^catbomb (\d+) (.*)/i, (msg) => {
    const user = msg.message.user;
    let number = msg.match[1];
    if (isInt(number)) {
      if (number > 9) {
        number = 9;
        msg.send('Catbombs are limited to 10 at a time. Enjoy');
      }

      for (let i = 0; i < number; i++) {
        const rand = Math.round(Math.random() * 15000);
        setTimeout(() => {
          msg.send(`https://cataas.com/cat/says/${encodeURI(msg.match[2])}?${uuidv1()}`);
        }, rand);
      }
      robot.logger.info(`${user.name} catbombed ${msg.message.text}`);
    } else {
      msg.say('naughty!');
      robot.logger.info(`${user.name} catbombed a non-number ${number}`);
    }
  });

  robot.hear(/^nasa apod$/i, (msg) => {
    const user = msg.message.user;
    const apiKey = process.env.NASA_API_KEY;

    robot.logger.info(`got nasa apiKey ${apiKey}`);

    // eslint-disable-next-line no-new
    new Promise((resolve, reject) => {
      robot.http(`https://api.nasa.gov/planetary/apod?api_key=${apiKey}`)
        .get((err, _response, body) => {
          if (err) {
            robot.logger.info(`http get error ${err}`);
            reject(err);
          } else {
            resolve(body);
          }
        })
        .then(body => JSON.parse(body))
        .then(body => robot.logger.info(`got json body ${body}`))
        .then(json => decode(json.value.explanation))
        .then(explanation => msg.send(explanation))
        .then(json => decode(json.value.hdurl))
        .then(hdurl => msg.send(hdurl))
        .catch(err => msg.reply(`error in 'nasa apod' ${err}`));
    });

    robot.logger.info(`${user.name} nasa info ${msg.message.text}`);
  });

  // point out topic changes
  robot.topic((msg) => {
    msg.send(`${msg.message.text}? TOPIC CHANGE! I'm telling!`);
  });

  // redis
  robot.hear(/^redis server info$/i, (msg) => {
    msg.send(client.server_info);
  });

  robot.hear(/^dump redis$/i, (msg) => {
    client.keys('hubot:storage:*', (err, keys) => {
      if (err) {
        msg.send('Error encountered with that redis thingy');
        robot.logger.info(`ERROR: ${err}`);
      }

      msg.send('----dump redis----');
      for (let i = 0, len = keys.length; i < len; i++) {
        msg.send(keys[i]);
      }
      msg.send('----end dump redis----');
    });
  });

  // AWESOME BOX
  robot.hear(/^awesome( info| help|)$/i, (msg) => {
    msg.send(`Familab Awesome Box
    Usage:
    Add: awesome @person The reason @person is awesome is for making a toaser with a jet engine. Woot!
      Adds an awesome box message for @person. It also records who sent it.
    List: awesome list
      Lists all of the current Awesome Box Entries
    Archive: awesome archive
      (Must be @board) Archives the current Awesome Box entries
    Archive list: awesome archive list
      Lists all of the Awesome's in the archive (may be a long list)
    Stats: awesome stats
      Gives some Awesome box stats
    Info/Help: awesome (info|help) 
      This message
    Search: <currently not implemented> 
    `);
  });

  // eslint-disable-next-line no-useless-escape
  robot.hear(/^awesome add @?([\w.-]+) (.*)$/i, (msg) => {
    const messageUser = msg.message.user;
    const name = msg.match[1].trim();
    const user = robot.adapter.client.rtm.dataStore.getDMByName(name);
    const currentDateTime = new Date();
    // redis hash of key, adding user, user who was awesome, message
    client.sadd(
      'awesome',
      `{
        "from":"${encodeURI(messageUser.name)}",
        "to":"${encodeURI(name)}",
        "message":"${encodeURI(msg.match[2])}",
        "datetime": "${currentDateTime}"
      }`
    );
    robot.send(
      user,
      `You just got an Awesome Box Message! "${msg.match[2]}" from @${messageUser.name}.`
    );
    msg.send(`Adding "@${name} ${msg.match[2]}" from @${messageUser.name}. Thanks!`);
    msg.send(`@${messageUser.name}++ for submitting an awesome box message`);
    robot.logger.info(`${messageUser.name} an awesome add ${msg.message.text}`);
  });

  robot.hear(/^awesome delete (\d+)$/i, (msg) => {
    const messageUser = msg.message.user;
    const key = msg.match[1];
    // redis hash of key, adding user, user who was awesome, message
    if (messageUser.name === 'craigske') { // U31NDNH4Y
      if (client.srem('awesome', key.toString) === 1) {
        msg.send(`removed ${key}`);
        robot.logger.info(`${messageUser.name} awesome delete ${msg.message.text}`);
      } else {
        msg.send(`FAILED to remove ${key}`);
        robot.logger.info(`${messageUser.name} awesome delete ${msg.message.text}`);
      }
    } else {
      msg.send(`${messageUser.name} You're not craigske, you bastard`);
    }
  });

  robot.hear(/^awesome list$/i, (msg) => {
    const messageUser = msg.message.user;
    client.smembers('awesome', (err, object) => {
      for (const [key, value] of Object.entries(object)) {
        const json = JSON.parse(value);
        msg.send(
          `${key}: *"@${json.to} ${decodeURI(json.message)}"* from @${json.from} at ${json.datetime}`
        );
        robot.logger.info(json, key, value);
      }
    });
    robot.logger.info(`${messageUser.name} awesome list`);
  });

  robot.router.get('/famibot/test/:message', (req, res) => {
    robot.messageRoom('CP3RNDEEL', `webhook /famibot/test/:message got GET ${req.body}`);
    res.send('OK');
  });

  robot.router.post('/famibot/test/:message', (req, res) => {
    const room = req.params.room;
    const data = JSON.parse(req.body.payload);
    const secret = data.secret;
    robot.messageRoom('CP3RNDEEL', `webhook /famibot/test/:message got POST 
      ----------BEGIN DATA----------
      ${data}
      ----------END DATA----------
      with secret ${secret} for room ${room}`);
    res.send('OK');
  });

  robot.router.post('/famibot/scores/heroku/keepalive', (req, res) => {
    robot.logger.info(`got ping from ${req} sending pong`);
    res.send('PONG');
  });

  robot.router.get('/famibot/scores/heroku/keepalive', (req, res) => {
    robot.logger.info(`got ping from ${req} sending pong`);
    res.send('PONG');
  });

  // error handling
  robot.error((err, msg) => {
    msg.send('I experienced an error. Someone should investigate');
    robot.logger.error(`DOES NOT COMPUTE. Got ${err} for ${msg.message.text}`);
  });
};
