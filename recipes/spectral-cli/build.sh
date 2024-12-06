#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch package.json to skip unnecessary prepare step
mv package.json package_old.json.bak
jq "del(.scripts.prepare)" < package.json.bak > package.json

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    stoplight-${PKG_NAME}-${PKG_VERSION}.tgz

# Run pnpm so that pnpm-licenses can create report
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create batch wrapper
tee ${PREFIX}/bin/spectral.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\spectral %*
EOF
