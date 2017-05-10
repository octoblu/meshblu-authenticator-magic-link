enableDestroy      = require 'server-destroy'
octobluExpress     = require 'express-octoblu'
Router             = require './router'
MagicLinkService   = require './services/magic-link-service'
EmailService       = require './services/email-service'

class Server
  constructor: (options) ->
    { @logFn, @disableLogging, @port } = options
    { @meshbluConfig, @emailDomains, @linkDomains } = options
    { @serviceName, @fromEmailAddress } = options
    { @sesKey, @sesSecret, @sesEmailUrl } = options
    { @_fakeCredentials, @_fakeSesClient } = options
    throw new Error 'Server: requires meshbluConfig' unless @meshbluConfig?
    throw new Error 'Server: requires emailDomains' unless @emailDomains?
    throw new Error 'Server: requires linkDomains' unless @linkDomains?
    throw new Error 'Server: requires serviceName' unless @serviceName?
    throw new Error 'Server: requires fromEmailAddress' unless @fromEmailAddress?
    throw new Error 'Server: requires sesKey' unless @sesKey?
    throw new Error 'Server: requires sesSecret' unless @sesSecret?

  address: =>
    @server.address()

  run: (callback) =>
    app = octobluExpress({ @logFn, @disableLogging })
    emailService = new EmailService {
      @emailDomains
      @linkDomains
      @serviceName
      @fromEmailAddress
      @sesEmailUrl
      @sesKey
      @sesSecret
      @_fakeSesClient
    }
    magicLinkService = new MagicLinkService {
      emailService
      @meshbluConfig
      @_fakeCredentials
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
