#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

yarn install
rm -f tree-sitter-fish.wasm
yarn pack --out ${PKG_NAME}-v${PKG_VERSION}.tgz
yarn licenses generate-disclaimer > third-party-licenses.txt
NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
npm install -g ${PKG_NAME}-v${PKG_VERSION}.tgz
