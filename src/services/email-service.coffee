_        = require 'lodash'
url      = require 'url'
showdown = require 'showdown'
isEmail  = require 'isemail'
ses      = require 'node-ses'
debug    = require('debug')('meshblu-authenticator-magic-link:email-service')

class EmailService
  constructor: (options) ->
    {
      @emailDomains
      @linkDomains
      @fromEmailAddress
      @serviceName
      @loginUrl
      sesEmailUrl
      sesKey
      sesSecret
      _fakeSesClient
    } = options
    throw new Error 'EmailService: requires serviceName' unless @serviceName?
    throw new Error 'EmailService: requires emailDomains' unless @emailDomains?
    throw new Error 'EmailService: requires sesKey' unless sesKey?
    throw new Error 'EmailService: requires sesSecret' unless sesSecret?
    throw new Error 'EmailService: requires linkDomains' unless @linkDomains?
    throw new Error 'EmailService: requires fromEmailAddress' unless @fromEmailAddress?
    @converter = new showdown.Converter()
    sesEmailUrl ?= 'https://email.us-west-2.amazonaws.com'
    @sesClient = _fakeSesClient ? ses.createClient { key: sesKey, secret: sesSecret, amazon: sesEmailUrl  }

  getEmailDomain: ({ email }) =>
    _.chain(email).split('@').tail().toLower().trim().value()

  getEmail: ({ email }) =>
    _.chain(email).toLower().trim().value()

  getMagicLink: ({ loginUrl, uuid, token }) =>
    parts = url.parse loginUrl, true
    parts.slashes = true
    parts.query.uuid = uuid
    parts.query.token = token
    return url.format parts

  getSubject: =>
    return "Sign-in to #{@serviceName} with this magic link"

  getHtml: ({ uuid, token, loginUrl }) =>
    return """
    <!DOCTYPE html>
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>#{@getSubject()}</title>
        <style type="text/css">
          body {margin: 0; padding: 0; min-width: 100%!important;}
        </style>
      </head>
      <body>
        <h3>Hello!</h3>

        As you've requested, we've generated you a <i>magic link</i> for <strong>#{@serviceName}</strong>.

        <h3>Click the <a href="#{@getMagicLink({ uuid, token, loginUrl })}" title="Magic Link">Magic Link</a> to sign-in.</h3>

        <span style="color: gray">
          You may copy/paste this link into your browser
          <br>
          #{@getMagicLink({ uuid, token, loginUrl })}
        </span>

        Cheers,

        The Team at <strong>Octoblu</strong>
      </body>
    </html>
    """

  getText: ({ uuid, token, loginUrl }) =>
    return """
      Hello!

      As you've requested, we've generated you a *magic link* for **#{@serviceName}**.

      You may copy/paste this link into your browser. #{@getMagicLink({ uuid, token, loginUrl })}

      Cheers,

      The Team at Octoblu
    """

  send: ({ uuid, token, email, loginUrl }, callback) =>
    email = @getEmail { email }
    @sesClient.sendEmail {
      to: email
      from: @fromEmailAddress
      subject: @getSubject()
      message: @getHtml({ uuid, token, loginUrl })
      altText: @getText({ uuid, token, loginUrl })
    }, (error) =>
      debug 'send email result', { error }
      return callback error if error?
      callback null

  validate: ({ email, loginUrl }, callback) =>
    @_validateEmail { email }, (error) =>
      return callback error if error?
      return callback @_createError 'Unauthorized loginUrl', 403 unless @_validLoginUrl { loginUrl }
      callback null

  _validateEmail: ({ email }, callback) =>
    email = @getEmail { email }
    return callback @_createError 'Missing email', 422 unless email?
    isEmail.validate email, {checkDNS: true}, (valid) =>
      return callback @_createError 'Invalid Email', 422 unless valid
      domain = @getEmailDomain { email }
      return callback @_createError 'Unauthorized email domain', 403 unless domain in @emailDomains
      callback null

  _validLoginUrl: ({ loginUrl }) =>
    { hostname } = url.parse loginUrl, true
    return _.some @linkDomains, (domain) =>
      return _.endsWith hostname, domain

  _createError: (message='Internal Service Error', code=500) =>
    error = new Error message
    error.code = code
    return error

module.exports = EmailService
