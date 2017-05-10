class MagicLinkService
  constructor: ({ @emailDomains }) ->
    throw new Error 'MagicLinkService: requires emailDomains' unless @emailDomains?
    
  generateLink: ({ email }, callback) =>
    return callback @_createError 'Missing email', 422 unless email?
    callback()

  _createError: (message='Internal Service Error', code=500) =>
    error = new Error message
    error.code = code
    return error

module.exports = MagicLinkService
