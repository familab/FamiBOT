url = require 'url'

redis = require 'redis'

identity =
  init: ->
    info = url.parse(process.env.REDISTOGO_URL or
                     process.env.REDISCLOUD_URL or
                     process.env.REDIS_URL or
                     process.env.BOXEN_REDIS_URL or
                     'redis://localhost:6379')
    @client = redis.createClient(info.port, info.hostname)
    @client.auth(info.auth.split(":")[1]) if info.auth

  findToken: (chatUser, callback) ->
    @client.get "ghid:chat:#{chatUser}", (err, githubUser) =>
      # redis err
      return callback(err: err, type: 'redis') if err

      # github->chat username missing
      return callback(err: 'missing', type: 'github user') unless githubUser

      @client.get "ghid:token:#{githubUser}", (err, token) ->
        # redis err
        return callback(err: err, type: 'redis') if err

        # ok
        callback(null, token)

  getGitHubUserAndToken: (chatUser, callback) ->
    @client.get "ghid:chat:#{chatUser}", (err, githubUser) =>
      # redis err
      return callback(err: err, type: 'redis') if err

      # github->chat username missing
      return callback(err: 'missing', type: 'github user') unless githubUser

      @client.get "ghid:token:#{githubUser}", (err, token) ->
        # redis err
        return callback(err: err, type: 'redis') if err

        # ok
        callback(null, githubUser, token)

  setGitHubUserAndToken: (githubUser, token, callback) ->
    @client.set "ghid:token:#{githubUser}", token, (err, reply) ->
      # redis err
      return callback(err: err, type: 'redis') if err

      # ok
      callback(null, reply)

  setChatUserForGitHubUser: (chatUser, githubUser, callback) ->
    @client.get "ghid:chat:#{chatUser}", (err, reply) =>
      # redis err
      return callback(err: err, type: 'redis') if err

      # github->chat username already exists
      return callback(err: 'existing', type: 'chat user', msg: reply) if reply

      @client.get "ghid:token:#{githubUser}", (err, token) =>
        # redis err
        return callback(err: err, type: 'redis') if err

        # github->token missing
        return callback(err: 'missing', type: 'token') unless token

        @client.set "ghid:chat:#{chatUser}", githubUser, (err, reply) ->
          # redis err
          return callback(err: err, type: 'redis') if err

          # ok
          callback(null, reply)

  forgetChatUser: (chatUser, callback) ->
    @client.get "ghid:chat:#{chatUser}", (err, github) =>
      # redis err
      return callback(err: err, type: 'redis') if err

      # github->chat username missing
      return callback(err: 'missing', type: 'chat user') unless github

      @client.del "ghid:chat:#{chatUser}", (err, reply) ->
        # redis err
        return callback(err: err, type: 'redis') if err

        # ok
        callback(null, reply)

  forgetToken: (chatUser, callback) ->
    @client.get "ghid:chat:#{chatUser}", (err, github) =>
      # redis err
      return callback(err: err, type: 'redis') if err

      # github->chat username missing
      return callback(err: 'missing', type: 'chat user') unless github

      @client.del "ghid:chat:#{chatUser}", (err, reply) =>
        # redis err
        return callback(err: err, type: 'redis') if err

        @client.del "ghid:token:#{github}", (err, reply) =>
          # redis err
          return callback(err: err, type: 'redis') if err

          # ok
          callback(null, reply)


module.exports = identity
