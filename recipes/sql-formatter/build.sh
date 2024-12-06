#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Package package.json so pnpm works
mv package.json package.json.bak
jq 'del(.scripts.prepare)' package.json.bak > package.json

# generate license disclaimer for the package
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/sql-formatter.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\sql-formatter %*
EOF
