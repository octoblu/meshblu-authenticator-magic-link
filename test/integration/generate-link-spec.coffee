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
    @sesClient =
      sendEmail: sinon.stub()
    serverOptions =
      port: undefined,
      disableLogging: true
      logFn: @logFn
      emailDomains: ['octoblu.com']
      linkDomains: ['example.com']
      _fakeCredentials:
        uuid: 'some-uuid'
        token: 'some-token'
      _fakeSesClient: @sesClient
      sesKey: 'some-ses-key'
      sesSecret: 'some-ses-secret'
      fromEmailAddress: 'superadmin@example.com'
      serviceName: 'Meshblu Authenticator Test'
      meshbluConfig:
        uuid: 'some-authenticator-uuid'
        token: 'some-authenticator-token'
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
    describe 'when called with everything it needs', ->
      beforeEach (done) ->
        @sesClient.sendEmail.yields null
        options =
          uri: '/links'
          baseUrl: "http://localhost:#{@serverPort}"
          json:
            email: 'some-email@octoblu.com'
            loginUrl: 'https://some.example.com/login'

        request.post options, (error, @response, @body) =>
          done error

      it 'should return a 204', ->
        expect(@response.statusCode).to.equal 204

      it 'should send the email', ->
        expect(@sesClient.sendEmail).to.have.been.calledWith {
          to: 'some-email@octoblu.com'
          from: 'superadmin@example.com'
          subject: 'Sign-in to Meshblu Authenticator Test with this magic link'
          message: """
            <p><strong>Hello!</strong></p>
            <p>We've generated your <em>magic link</em> for <strong>Meshblu Authenticator Test</strong>. You can use the link below.</p>
            <h3 id="signinlinkhttpssomeexamplecomloginuuidsomeuuidtokensometoken"><a href="https://some.example.com/login?uuid=some-uuid&token=some-token">Sign-in Link</a></h3>
            <p>Cheers,</p>
            <p>The Team at Octoblu</p>
          """
          altText: """
            Hello!

            We've generated your magic link for Meshblu Authenticator Test. You can use the link below.

            https://some.example.com/login?uuid=some-uuid&token=some-token

            Cheers,

            The Team at Octoblu
          """
        }

    describe 'when called without an email', ->
      beforeEach (done) ->
        options =
          uri: '/links'
          baseUrl: "http://localhost:#{@serverPort}"
          json:
            loginUrl: 'https://some.example.com/login'

        request.post options, (error, @response, @body) =>
          done error

      it 'should return a 422', ->
        expect(@response.statusCode).to.equal 422

    describe 'when called without a loginUrl', ->
      beforeEach (done) ->
        options =
          uri: '/links'
          baseUrl: "http://localhost:#{@serverPort}"
          json:
            email: 'some-email@octoblu.com'

        request.post options, (error, @response, @body) =>
          done error

      it 'should return a 422', ->
        expect(@response.statusCode).to.equal 422

    describe 'when called with an invalid email', ->
      beforeEach (done) ->
        options =
          uri: '/links'
          baseUrl: "http://localhost:#{@serverPort}"
          json:
            loginUrl: 'https://some.example.com/login'
            email: 'some-email@invalid.com'

        request.post options, (error, @response, @body) =>
          done error

      it 'should return a 403', ->
        expect(@response.statusCode).to.equal 403

    describe 'when called with an invalid loginUrl', ->
      beforeEach (done) ->
        options =
          uri: '/links'
          baseUrl: "http://localhost:#{@serverPort}"
          json:
            loginUrl: 'https://some.invalid.com/login'
            email: 'some-email@octoblu.com'

        request.post options, (error, @response, @body) =>
          done error

      it 'should return a 403', ->
        expect(@response.statusCode).to.equal 403
