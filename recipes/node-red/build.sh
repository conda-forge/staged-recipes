#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# env
export SRC_DIR_1=./src/github.com/node-red/node-red
find .
mkdir -p ./tgt/
export TAR_GET=./tgt/${PKG_NAME}-${PKG_VERSION}.tgz

# Create package archive and install globally
pnpm pack ./src/github.com/node-red/node-red
pnpm store path
pnpm store add -ddd \
    --global \
    --build-from-source \
    ${TAR_GET}
    # ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install ${TAR_GET}
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/node-red.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\nodered %*
EOF
