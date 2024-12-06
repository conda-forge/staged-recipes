#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/napi-rs-cli-${PKG_VERSION}.tgz

# Create batch wrapper
tee ${PREFIX}/bin/napi.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\napi %*
EOF
