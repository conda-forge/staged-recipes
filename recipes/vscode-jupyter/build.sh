#!/bin/bash

set -exuo pipefail

export ZEROMQ_VERSION=$(jq -r '.dependencies["zeromq"]' package.json)
npm install "zeromq@${ZEROMQ_VERSION/^}" --zmq-shared --build-from-source
npm install
rm -r node_modules/zeromq/prebuilds
npm run package
code-server --install-extension ms-toolsai-jupyter-insiders.vsix
find ${PREFIX}/share/code-server/extensions/ms-toolsai.jupyter-*/out -name '*.js.map' -delete
