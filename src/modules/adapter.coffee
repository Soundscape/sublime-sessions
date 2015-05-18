_ = require 'lodash'
hello = require 'hellojs'

module.exports = (options) ->
  defaults =
    name: 'Sublime'
    base: 'http://localhost:3000/'
    oauth:
      version: '2'
      auth: 'http://localhost:3000/api/oauth2/authorize'
      grant: 'http://localhost:3000/api/oauth2/token'
      response_type: 'token'

    scope:
      basic: ''

    get:
      me: 'api/profile'

    jsonp: false
    xhr: (p, q) -> true

  hello.init
    sublime: _.extend defaults, options

  return
