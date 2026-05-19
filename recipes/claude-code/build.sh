#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally (skip scripts to avoid auth check)
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --ignore-scripts \
    ${SRC_DIR}/*.tgz

# Generate third-party license file
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
