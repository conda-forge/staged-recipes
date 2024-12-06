#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${PKG_NAME}-cli-${PKG_VERSION}.tgz

# Patch package.json to remove devDependencies which are not needed for license report
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

# Run pnpm so that pnpm-licenses can create report
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create batch wrapper
tee ${PREFIX}/bin/commitlint.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\commitlint %*
EOF
