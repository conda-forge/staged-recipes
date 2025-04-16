#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt

tee ${PREFIX}/bin/eslint.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\eslint %*
EOF
