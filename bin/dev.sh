#!/bin/bash

export HUBOT_HEROKU_KEEPALIVE_URL=https://famibot.herokuapp.com/famibot/scores
export PATH="node_modules/.bin:node_modules/hubot/node_modules/.bin:$PATH"

echo not so fast, dirty coder. Linting!
npm run lint

exec nodemon --exec "bash" node_modules/.bin/hubot --name "FamiBOT" "$@" -l --alias "Jarvis"
