https = require 'https'

request = (path, token, callback) ->
  options =
    host: 'api.github.com'
    path: path
    method: 'GET'
    headers:
      'user-agent': 'hubot'

  if token
    options.headers['authorization'] = "token #{token}"

  req = https.request options, (res) ->
    data = ''

    res.on 'data', (chunk) ->
      data += chunk

    res.on 'end', ->
      data = JSON.parse(data)
      callback(null, data)

  req.on 'error', (err) ->
    callback(err, null)

  req.end()

module.exports =
  request: request
