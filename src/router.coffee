MagicLinkController = require './controllers/magic-link-controller'

class Router
  constructor: ({ @magicLinkService }) ->
    throw new Error 'Missing magicLinkService' unless @magicLinkService?

  route: (app) =>
    magicLinkController = new MagicLinkController { @magicLinkService }

    app.post '/links', magicLinkController.generateLink

module.exports = Router
