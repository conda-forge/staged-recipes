#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

env
# export SRC_DIR=./src/github.com/node-red/node-red
find .
# echo ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create package archive and install globally
pnpm pack src/github.com/node-red/node-red
pnpm add -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/node-red.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\nodered %*
EOF
