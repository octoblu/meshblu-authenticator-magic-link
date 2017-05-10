class MagicLinkController
  constructor: ({@magicLinkService}) ->
    throw new Error 'MagicLinkController magicLinkService' unless @magicLinkService?

  generateLink: (request, response) =>
    { email } = request.body
    @magicLinkService.generateLink { email }, (error) =>
      return response.sendError(error) if error?
      response.sendStatus(204)

module.exports = MagicLinkController
