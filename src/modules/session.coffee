_ = require 'lodash'
hello = require 'hellojs'
When = require 'when'
Core = require 'sublime-core'

states =
  unauthenticated:
    signIn: (inst, dfr) ->
      hello(inst.network).login force: false,
        (res) =>
          if !res.error
            inst._data = res
            @setMachineState @authenticated
            dfr.resolve inst
          else
            dfr.reject res.error
      return

  authenticated:
    signOut: (inst, dfr) ->
      hello inst.network
        .logout (res) =>
          if !res.error
            inst._data = null
            inst._profile = null
            @setMachineState @unauthenticated
            dfr.resolve inst
          else
            dfr.reject res.error
      return

    profile: (inst, dfr) ->
      hello inst.network
        .api '/me'
        .then (res) ->
          if !res.error
            inst._profile = res
            dfr.resolve res
          else
            dfr.reject res.error
      return

# Provides a user session container
class Session extends Core.Stateful
  # Construct a new Session
  #
  # @param [String] network The name of the network/adapter
  constructor: (network) ->
    super(states)
    @network = network

  # Sign in
  signIn: () ->
    dfr = When.defer()
    @apply 'signIn', @, dfr
    dfr.promise

  # Sign out
  signOut: () ->
    dfr = When.defer()
    @apply 'signOut', @, dfr
    dfr.promise

  # Fetch the user profile
  profile: () ->
    dfr = When.defer()
    @apply 'profile', @, dfr
    dfr.promise

  # Checks if this session has yet to expire
  isAvailable: () ->
    auth = hello(@network).getAuthResponse()
    time = (new Date()).getTime() / 1000

    auth && auth.access_token && auth.expires > time

  # Checks if this session is currently authenticated
  isActive: () ->
    @state() == 'authenticated' && @isAvailable()

module.exports = Session
