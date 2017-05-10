class MagicLinkController
  constructor: ({@magicLinkService}) ->
    throw new Error 'MagicLinkController magicLinkService' unless @magicLinkService?

  generateLink: (request, response) =>
    { email } = request.body
    @magicLinkService.generateLink { email }, (error, result) =>
      return response.sendError(error) if error?
      response.status(200).send(result)

module.exports = MagicLinkController
