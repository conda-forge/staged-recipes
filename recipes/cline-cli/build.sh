#!/usr/bin/env bash
set -exo pipefail

# Install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    cline-${PKG_VERSION}.tgz

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create wrapper scripts for cline
tee ${PREFIX}/bin/cline << 'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/cline/bin/cline" "$@"
EOF
chmod +x ${PREFIX}/bin/cline

tee ${PREFIX}/bin/cline.cmd << 'EOF'
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\cline\bin\cline %*
EOF
