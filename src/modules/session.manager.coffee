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

# Manager for all use sessions
class SessionManager extends Core.CoreObject
  # Construct a new SessionManager
  #
  # @param [Array] networks The networks to provide for
  # @param [Object] keys The Hello.js network adapters
  # @param [Object] options The configuration for Hello.js initialization
  constructor: (networks, keys, options) ->
    super()
    @_networks = networks
    @_sessions = {}
    init keys, options

    for network in @_networks
      @session network

  # Create or retrieve the session for the given network.
  # If no network is specified it retrieves the first active or available session
  #
  # @param [String] network The name of the network
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

  # Checks if there is an authenticated session
  authenticated: () ->
    session = @session()
    if !session then false
    else session.state() == 'authenticated'

  # Retrieves all sessions
  sessions: () ->
    @_networks.map (network) =>
      @session network

  # Retrieves all available sessions and provides the ability to sign out of all instances
  availableSessions: () ->
    res = @sessions().filter (session) ->
      session.isAvailable()

    res.signOut = () ->
      res.forEach (session) ->
        session.signOut()

    res

  # Retrieves all inactive sessions
  inactiveSessions: () ->
    @sessions().filter (session) ->
      !session.isActive()

  # Retrieves all active sessions and provides the ability to sign out of all instances
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

  # Sign into te first available session
  signIn: () ->
    session = @session()
    if !session
      throw new Error 'No session is available'

    session.signIn()

  # Sign out of all available sessions
  signOut: () ->
    @availableSessions().signOut()

module.exports = SessionManager
