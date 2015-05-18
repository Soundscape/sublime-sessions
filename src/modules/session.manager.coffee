_ = require 'lodash'
hello = require 'hellojs'
When = require 'when'
Session = require './session'
Core = require 'sublime-core'

init = (keys, options) ->
  hello.init(_.extend({}, keys), _.extend(
    'redirect_uri': '/auth.html'
    'oauth_proxy': 'https://auth-server.herokuapp.com/proxy'
    scope: 'friends,email'
  , options))

class SessionManager extends Core.CoreObject
  constructor: (networks, keys, options) ->
    super()
    @_networks = networks
    @_sessions = {}
    init keys, options

    for network in @_networks
      @session network

  session: (network) ->
    if !network
      active = @activeSessions()
      available = @availableSessions();

      if active.length > 0
        return active[0]

      if available.length > 0
        return available[0]

      return null

    if -1 == @_networks.indexOf network then null
    else @_sessions[network] = @_sessions[network] or new Session network

  authenticated: () ->
    session = @session()
    if !session then false
    else session.state() == 'authenticated'

  sessions: () ->
    @_networks.map (network) =>
      @session network

  availableSessions: () ->
    res = @sessions().filter (session) ->
      session.isAvailable()

    res.signOut = () ->
      res.forEach (session) ->
        session.signOut()

    res

  inactiveSessions: () ->
    @sessions().filter (session) ->
      !session.isActive()

  activeSessions: () ->
    res = @sessions().filter (session) ->
      session.isActive()

    res.signOut = () ->
      dfr = When.defer()

      targets = res.forEach (session) -> session.signOut()

      When.all targets
      .then () ->
        dfr.resolve()
        return
      , (error) ->
        dfr.reject()
        return

      dfr.promise

    res

  signIn: () ->
    session = @session()
    if !session
      throw new Error 'No session is available'

    session.signIn()

  signOut: () ->
    @availableSessions().signOut()

module.exports = SessionManager
