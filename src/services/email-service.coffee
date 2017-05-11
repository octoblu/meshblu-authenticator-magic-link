_              = require 'lodash'
url            = require 'url'
isEmail        = require 'isemail'
ses            = require 'node-ses'
generateEmail  = require '../components/link-email'
debug          = require('debug')('meshblu-authenticator-magic-link:email-service')

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

  getText: ({ magicLink, serviceName }) =>
    return """
      Hello!

      As you've requested, we've generated you a *magic link* for #{serviceName}.

      You may copy/paste this link into your browser. #{magicLink}

      Cheers,

      The Team at Octoblu
    """

  send: ({ uuid, token, email, loginUrl }, callback) =>
    email = @getEmail { email }
    magicLink = @getMagicLink { uuid, token, loginUrl }
    subject   = @getSubject()
    message   = generateEmail { email, magicLink, subject, @serviceName, @fromEmailAddress }
    altText   = @getText { magicLink, @serviceName }
    @sesClient.sendEmail {
      to: email
      from: @fromEmailAddress
      subject,
      message,
      altText,
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
