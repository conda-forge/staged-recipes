#!/usr/bin/env bash
set -exo pipefail

# Create license report for dependencies
pnpm install --prod --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Install globally
pnpm pack --config.ignore-scripts=true
npm install -ddd \
    --global \
    --prefix "${PREFIX}" \
    --ignore-scripts \
    --no-bin-links \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# Create wrapper scripts
tee ${PREFIX}/bin/tslab << 'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/tslab/bin/tslab" "$@"
EOF
chmod +x ${PREFIX}/bin/tslab

# for windows
mkdir -p ${PREFIX}/Scripts
tee ${PREFIX}/Scripts/tslab.cmd << 'EOF'
@echo off
"%CONDA_PREFIX%\node.exe" "%CONDA_PREFIX%\node_modules\tslab\bin\tslab" %*
EOF
