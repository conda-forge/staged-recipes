#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create license report for dependencies
pnpm install --production
pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file=third-party-licenses.txt
pnpm pack

npm install --global ${PKG_NAME}-${PKG_VERSION}.tgz
