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

class Session extends Core.Stateful
  constructor: (network) ->
    super(states)
    @network = network

  signIn: () ->
    dfr = When.defer()
    @apply 'signIn', @, dfr
    dfr.promise

  signOut: () ->
    dfr = When.defer()
    @apply 'signOut', @, dfr
    dfr.promise

  profile: () ->
    dfr = When.defer()
    @apply 'profile', @, dfr
    dfr.promise

  isAvailable: () ->
    auth = hello(@network).getAuthResponse()
    time = (new Date()).getTime() / 1000

    auth && auth.access_token && auth.expires > time

  isActive: () ->
    @state() == 'authenticated' && @isAvailable()

module.exports = Session
