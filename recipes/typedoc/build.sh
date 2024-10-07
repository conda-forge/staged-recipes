#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
mv package.json package.json.bak
jq 'del(.scripts.prepare)' package.json.bak > package.json

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\typedoc %*
EOF
