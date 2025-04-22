#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

yarn config set enableScripts false
yarn config set enableImmutableInstalls false
yarn install

# Create package archive
rm -f tree-sitter-fish.wasm
yarn pack

# Symlink run-s from npm-run-all to ${SRC_DIR}/bin and add this folder to path
ln -sf ${SRC_DIR}/node_modules/npm-run-all/bin/run-s/index.js ${SRC_DIR}/bin/run-s
export PATH="${SRC_DIR}/bin:${PATH}"

# Install the packed tgz globally
npm install -ddd --global --omit=dev ${SRC_DIR}/package.tgz

# Create license report for dependencies
yarn plugin import https://raw.githubusercontent.com/mhassan1/yarn-plugin-licenses/v0.15.0/bundles/@yarnpkg/plugin-licenses.js
yarn licenses generate-disclaimer > third-party-licenses.txt
