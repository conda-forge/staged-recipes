#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch package.json to skip unnecessary prepare step
mv package.json package.json.bak
jq "del(.scripts.prepare)" < package.json.bak > package.json

# Create package archive and install globally
PKG_VERSION=$(jq -r .version package.json)
PKG_NAME=$(jq -r .name package.json | sed 's|@||;s|/|-|g')
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --prefix="${PREFIX}" \
    --build-from-source \
    "./${PKG_NAME}-${PKG_VERSION}.tgz"

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
