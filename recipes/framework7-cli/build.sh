#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include/glib-2.0 -I${PREFIX}/lib/glib-2.0/include"

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
