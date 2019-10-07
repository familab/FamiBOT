FROM node:10-alpine

LABEL   author="Craig Skelton <cskelton@gmail.com>" \
        version="1.0.0" \
        description="testfamibot the test bot for Famibot changes"

# globals
RUN npm i -g coffeescript

# Create hubot user
RUN addgroup hubot
RUN adduser -h /hubot -s /bin/bash -g hubot -S hubot
USER hubot:hubot

WORKDIR /app/hubot
COPY --chown=hubot:hubot . /app/hubot/

RUN npm i

EXPOSE 8080

RUN pwd
RUN ls -lah bin
# And go
ENTRYPOINT ["bin/hubot", "--adapter slack"]