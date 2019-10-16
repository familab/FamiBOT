FROM node:10-alpine

LABEL   author="Craig Skelton <cskelton@gmail.com>" \
        version="1.0.0" \
        description="testfamibot the test bot for Famibot changes"

# globals
RUN apk --update add redis
RUN npm i -g coffeescript

# Create hubot user
RUN addgroup hubot
RUN adduser -h /hubot -s /bin/bash -g hubot -S hubot
USER hubot:hubot

WORKDIR /app/hubot
COPY --chown=hubot:hubot . /app/hubot/

EXPOSE 8080
ENTRYPOINT ["bin/hubot", "--adapter slack", "--name \"FamiBOT\", "-l" "--alias \"Jarvis\""]
