enableDestroy      = require 'server-destroy'
octobluExpress     = require 'express-octoblu'
Router             = require './router'
MagicLinkService = require './services/magic-link-service'

class Server
  constructor: (options) ->
    { @logFn, @disableLogging, @port } = options
    { @meshbluConfig, @emailDomains } = options
    throw new Error 'Server: requires meshbluConfig' unless @meshbluConfig?
    throw new Error 'Server: requires emailDomains' unless @emailDomains?

  address: =>
    @server.address()

  run: (callback) =>
    app = octobluExpress({ @logFn, @disableLogging })

    magicLinkService = new MagicLinkService { @emailDomains }
    router = new Router {@meshbluConfig, magicLinkService}

    router.route app

    @server = app.listen @port, callback
    enableDestroy @server

  stop: (callback) =>
    @server.close callback

  destroy: =>
    @server.destroy()

module.exports = Server
