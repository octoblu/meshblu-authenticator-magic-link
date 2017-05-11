const React          = require('react')
const ReactHTMLEmail = require('react-html-email')
const { Box, Email, Image, Item, Span, A } = ReactHTMLEmail

const css = `
@media only screen and (max-device-width: 480px) {
  font-size: 20px !important;
}
body {
  font-family: Arial, Helvetica, sans-serif;
  font-size: 16px;
}
`.trim()

const buttonStyles = {
  border: 'none',
  padding: '10px 20px',
  fontSize: '18px',
  borderRadius: '2px',
  background: '#e3e3e3',
  textAlign: 'center',
  textDecoration: 'none',
  appearance: 'none',
  background: '#14568f',
  color: 'white',
}

ReactHTMLEmail.injectReactEmailAttributes()
ReactHTMLEmail.configStyleValidator({ warn: process.env.NODE_ENV == 'development' })

function generateEmail({ magicLink, subject, serviceName, fromEmailAddress, email }) {
  return (
    <Email title={subject} headCSS={css} cellSpacing={20}>
      <Item>
        <Span fontSize={18}>Hello!</Span>
      </Item>
      <Item>
        <Span>As you've requested, we've generated you a <Span fontWeight="bold">magic link</Span> for {serviceName}.</Span>
        <Span> Please use the one time link below to sign-in.</Span>
      </Item>
      <Item style={{ textAlign: 'center' }}>
        <A href={magicLink} style={buttonStyles}>Sign-in</A>
      </Item>
      <Item style={{ textAlign: 'center' }}>
        <Span color="gray" fontSize={12}>
          You may copy/paste this link into your browser.
        </Span>
      </Item>
      <Item style={{ textAlign: 'center' }}>
        <Span>
          {magicLink}
        </Span>
      </Item>
      <Item style={{ textAlign: 'center' }}>
        <Span color="gray" fontSize={12}>This link is intended for {email}, if this is not you please contact {fromEmailAddress}</Span>
      </Item>
      <Item>
        <Span>
          Enjoy,
        </Span>
      </Item>
      <Item>
        <Span>
          The Team at <Span fontWeight="bold">Octoblu</Span>
        </Span>
      </Item>
    </Email>
  )
}

module.exports = function(options) {
  return ReactHTMLEmail.renderEmail(generateEmail(options))
};
