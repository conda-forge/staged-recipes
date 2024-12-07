#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create batch wrapper
tee ${PREFIX}/bin/cspell.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\cspell %*
EOF
