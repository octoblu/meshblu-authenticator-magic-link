{beforeEach, afterEach, describe, it} = global
{expect}      = require 'chai'
sinon         = require 'sinon'
shmock        = require '@octoblu/shmock'
request       = require 'request'
enableDestroy = require 'server-destroy'
Server        = require '../../src/server'

describe 'Generate Link', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d
    enableDestroy @meshblu

    @logFn = sinon.spy()
    serverOptions =
      port: undefined,
      disableLogging: true
      logFn: @logFn
      emailDomains: ['example.com']
      meshbluConfig:
        hostname: 'localhost'
        protocol: 'http'
        resolveSrv: false
        port: @meshblu.address().port

    @server = new Server serverOptions

    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach ->
    @meshblu.destroy()
    @server.destroy()

  describe 'On POST /links', ->
    describe 'when called with an email', ->
      beforeEach (done) ->
        options =
          uri: '/links'
          baseUrl: "http://localhost:#{@serverPort}"
          json:
            email: 'some-email@octoblu.com'

        request.post options, (error, @response, @body) =>
          done error

      it 'should return a 200', ->
        expect(@response.statusCode).to.equal 200

    describe 'when called without an email', ->
      beforeEach (done) ->
        options =
          uri: '/links'
          baseUrl: "http://localhost:#{@serverPort}"
          json: true

        request.post options, (error, @response, @body) =>
          done error

      it 'should return a 422', ->
        expect(@response.statusCode).to.equal 422
