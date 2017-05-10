enableDestroy      = require 'server-destroy'
octobluExpress     = require 'express-octoblu'
Router             = require './router'
MagicLinkService = require './services/magic-link-service'

class Server
  constructor: (options) ->
    { @logFn, @disableLogging, @port } = options
    { @meshbluConfig, @emailDomains } = options
    { @sesKey, @sesSecret } = options
    { @_fakeCredentials, @_fakeSesClient } = options
    throw new Error 'Server: requires meshbluConfig' unless @meshbluConfig?
    throw new Error 'Server: requires emailDomains' unless @emailDomains?
    throw new Error 'Server: requires sesKey' unless @sesKey?
    throw new Error 'Server: requires sesSecret' unless @sesSecret?

  address: =>
    @server.address()

  run: (callback) =>
    app = octobluExpress({ @logFn, @disableLogging })

    magicLinkService = new MagicLinkService {
      @meshbluConfig
      @emailDomains
      @_fakeCredentials
      @_fakeSesClient
      @sesKey
      @sesSecret
    }
    router = new Router { @meshbluConfig, magicLinkService }

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server
