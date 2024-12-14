#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch package.json to remove unneeded prepare step
mv package.json package.json.bak
jq 'del(.scripts.prepare)' package.json.bak > package.json

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
     ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Remove some unneeded vendored binaries
pushd ${PREFIX}/lib/node_modules/gatsby-cli/node_modules/
    find -name *.glibc.node | xargs -I % rm %
    rm -rf clipboardy/fallbacks/linux/xsel
popd

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt
