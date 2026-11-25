#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

npm pack --ignore-scripts
npm install \
    --global \
    --no-bin-links \
    --ignore-scripts \
    --omit=optional \
    "${SRC_DIR}/moonshot-ai-${PKG_NAME}-${PKG_VERSION}.tgz"

mkdir -p "${PREFIX}/bin"
tee "${PREFIX}/bin/kimi" << 'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/@moonshot-ai/kimi-code/dist/main.mjs" "$@"
EOF
chmod +x "${PREFIX}/bin/kimi"

tee "${PREFIX}/bin/kimi.cmd" << 'EOF'
@echo off
call node "%CONDA_PREFIX%\lib\node_modules\@moonshot-ai\kimi-code\dist\main.mjs" %*
EOF
