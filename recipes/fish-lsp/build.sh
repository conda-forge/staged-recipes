#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

yarn install
yarn pack
yarn licenses generate-disclaimer > third-party-licenses.txt
NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
npm install -g ${PKG_NAME}-v${PKG_VERSION}.tgz
