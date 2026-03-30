#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally from local source
tgz=$(npm pack --ignore-scripts)
npm install -ddd \
    --global \
    ${SRC_DIR}/${tgz}

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
