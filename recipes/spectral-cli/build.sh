#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mv package.json package.json.bak
jq "del(.scripts.prepare)" < package.json.bak > package.json

# Run pnpm so that pnpm-licenses can create report
pnpm install
pnpm pack

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    stoplight-${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create batch wrapper
tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\spectral %*
EOF
