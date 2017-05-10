_              = require 'lodash'
envalid        = require 'envalid'
MeshbluConfig  = require 'meshblu-config'
SigtermHandler = require 'sigterm-handler'
Server         = require './src/server'

strListValidator = envalid.makeValidator (value) =>
  return throw new Error 'Expected a string' unless _.isString value
  result = _.split(value, ',')
  return throw new Error 'List cannot be empty' if _.isEmpty result
  return result

envConfig = {
  PORT: envalid.num({ default: 80, devDefault: 3000 })
  EMAIL_DOMAINS: strListValidator { desc: 'comma-seperated list of whitelisted domains' }
  SES_KEY: envalid.str({ desc: 'AWS Access Key for SES' })
  SES_SECRET: envalid.str({ desc: 'AWS Secret Key for SES' })
}

class Command
  constructor: ->
    env = envalid.cleanEnv process.env, envConfig
    @serverOptions = {
      meshbluConfig : new MeshbluConfig().toJSON()
      port          : env.PORT
      emailDomains  : env.EMAIL_DOMAINS
      sesKey        : env.SES_KEY
      sesSecret     : env.SES_SECRET
    }

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    server = new Server @serverOptions
    server.run (error) =>
      return @panic error if error?

      { port } = server.address()
      console.log "Magic Link Service listening on port: #{port}"

    sigtermHandler = new SigtermHandler()
    sigtermHandler.register server.stop

command = new Command()
command.run()
