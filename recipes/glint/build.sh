#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
yarn
cd packages/core
# pnpm install
# pnpm pack

# Create package archive and install globally
npm run build
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/packages/core/${PKG_NAME}-core-${PKG_VERSION}.tgz

# Create license report for dependencies
# pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %CONDA_PREFIX%\bin\node %PREFIX%\bin\glint %*
EOF
