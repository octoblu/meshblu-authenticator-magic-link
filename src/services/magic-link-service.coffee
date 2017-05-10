_                     = require 'lodash'
moment                = require 'moment'
isEmail               = require 'isemail'
MeshbluHttp           = require 'meshblu-http'
{DeviceAuthenticator} = require 'meshblu-authenticator-core'
debug                 = require('debug')('meshblu-authenticator-magic-link:magic-link-service')
DEFAULT_PASSWORD      = 'idk-man-doesnt-matter'

class MagicLinkService
  constructor: ({ @emailDomains, meshbluConfig, @sesKey, @sesSecret, @_fakeCredentials }) ->
    throw new Error 'MagicLinkService: requires emailDomains' unless @emailDomains?
    throw new Error 'MagicLinkService: requires meshbluConfig' unless meshbluConfig?
    throw new Error 'MagicLinkService: requires sesKey' unless @sesKey?
    throw new Error 'MagicLinkService: requires sesSecret' unless @sesSecret?
    @authenticatorName = 'Magic Link Authenticator'
    @authenticatorUuid = meshbluConfig.uuid
    throw new Error 'MagicLinkService: requires an authenticator uuid' unless @authenticatorUuid?
    @meshbluHttp = new MeshbluHttp meshbluConfig
    @meshbluHttp.setPrivateKey meshbluConfig.privateKey
    @deviceModel = new DeviceAuthenticator {
      @authenticatorUuid
      @authenticatorName
      @meshbluHttp
    }

  generateLink: ({ email }, callback) =>
    return callback @_createError 'Missing email', 422 unless email?
    @_validateRequest { email }, (error) =>
      return callback error if error?
      @generateCredentials { email }, callback

  generateCredentials: ({ email }, callback) =>
    return callback @_createError 'Missing email', 422 unless email?
    return callback null, @_fakeCredentials if @_fakeCredentials?
    @_findOrCreate { email }, (error, uuid) =>
      return callback error if error?
      @_generateToken { uuid }, (error, { uuid, token }={}) =>
        return callback error if error?
        callback null, { uuid, token }

  _createDevice: ({ email }, callback) =>
    searchId = @_generateSearchId { email }
    query = {}
    query['meshblu.search.terms'] = { $in: [ searchId ] }
    @deviceModel.create {
      query: query
      data: { user: { email } }
      user_id: searchId
      secret: DEFAULT_PASSWORD
    }, (error, device) =>
      return callback error if error?
      callback null, _.get(device, 'uuid')

  _findDevice: ({ email }, callback) =>
    searchId = @_generateSearchId { email }
    query = {}
    query['meshblu.search.terms'] = { $in: [searchId] }
    @deviceModel.findVerified { query, password: DEFAULT_PASSWORD }, (error, device) =>
      return callback error if error?
      callback null, _.get device, 'uuid'

  _findOrCreate: ({ email }, callback) =>
    debug 'maybe create device', { email }
    @_findDevice { email }, (error, uuid) =>
      return callback error if error?
      return @_updateDevice { uuid, email }, callback if uuid?
      @_createDevice { email }, (error, uuid) =>
        return callback error if error?
        @_updateDevice { uuid, email }, callback

  _generateSearchId: ({ email }) =>
    email = email.toLowerCase().trim()
    return "authenticator:#{@authenticatorUuid}:#{email}"

  _generateToken: ({ uuid }, callback) =>
    debug 'generate token', uuid
    @meshbluHttp.generateAndStoreToken uuid, callback

  _updateDevice: ({ uuid, email }, callback) =>
    searchId = @_generateSearchId { email }
    query =
      $addToSet: { 'meshblu.search.terms': searchId }
      $set: {
        'user.email': email
        'user.updatedAt': moment().utc().toJSON()
        'user.loggedOutAt': null
      }
    @meshbluHttp.updateDangerously uuid, query, (error) =>
      return callback error if error?
      callback null, uuid

  _validateRequest: ({ email }, callback) =>
    return callback @_createError 'Missing email', 422 unless email?
    isEmail.validate email, {checkDNS: true}, (valid) =>
      return callback @_createError 'Invalid Email', 422 unless valid
      domain = _.chain(email).split('@').tail().toLower().trim().value()
      return callback @_createError 'Unauthorized email domain', 403 unless domain in @emailDomains
      callback null

  _createError: (message='Internal Service Error', code=500) =>
    error = new Error message
    error.code = code
    return error

module.exports = MagicLinkService
