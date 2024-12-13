#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Patch package.json to remove packageManager key so that
# pnpm-licenses can be used to generate license report
mv package.json package.json.bak
jq 'del(.packageManager)' package.json.bak > package.json

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/prisma-lint.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\prisma-lint %*
EOF
