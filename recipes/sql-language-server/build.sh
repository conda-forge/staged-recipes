#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pnpm install
pnpm pack

npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
