FROM alpine

LABEL   author="Craig Skelton <cskelton@gmail.com>" \
        version="1.0.0" \
        description="testfamibot the test bot for Famibot changes"

# Install dependencies
RUN apk update && apk upgrade \
  && apk add redis \
  && apk add nodejs \
  && apk add python \
  && apk add curl \
  && curl -sS https://bootstrap.pypa.io/get-pip.py | python \
  && pip install awscli \
  && npm install -g npm \
  && npm install -g coffeescript \
  && npm install -g yo generator-hubot \
  && apk --purge -v del py-pip \
  && rm -rf /var/cache/apk/*

# Create hubot user
RUN adduser -h /hubot -s /bin/bash -S hubot
USER  hubot
WORKDIR /hubot

# Install hubot
RUN yo hubot --owner="Craig/FamiLab" --name="testfamibot" --description="tesing is good, right?" --defaults
COPY package.json package.json
RUN npm install
ADD external-scripts.json external-scripts.json

EXPOSE 8080

# And go
ENTRYPOINT ["/bin/sh", "-c", "bin/hubot --adapter slack"]