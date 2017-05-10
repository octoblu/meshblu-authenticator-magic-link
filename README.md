# meshblu-authenticator-magic-link

# Table of Contents

* [Introduction](#introduction)
* [Getting Started](#getting-started)
  * [Install](#install)
* [Usage](#usage)
  * [Default](#default)
  * [Docker](#docker)
    * [Development](#development)
    * [Production](#production)
  * [Debugging](#debugging)
  * [Test](#test)
* [License](#license)

# Introduction

Magic Link (passwordless) authenticator for [Meshblu](https://github.com/octoblu/meshblu)

# Getting Started

## Install

```bash
git clone https://github.com/octoblu/meshblu-authenticator-magic-link.git
cd /path/to/meshblu-authenticator-magic-link
npm install
```

# Usage

## Default

```javascript
node command.js
```

## Docker

### Development

```bash
docker build -t local/meshblu-authenticator-magic-link .
docker run --rm -it --name meshblu-authenticator-magic-link-local -p 8888:80 local/meshblu-authenticator-magic-link
```

### Production

```bash
docker pull quay.io/octoblu/meshblu-authenticator-magic-link
docker run --rm -p 8888:80 quay.io/octoblu/meshblu-authenticator-magic-link
```

## Debugging

```bash
env DEBUG='meshblu-authenticator-magic-link*' node command.js
```

## Test

```bash
npm test
```

## License

MIT License

Copyright (c) 2017 Octoblu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
