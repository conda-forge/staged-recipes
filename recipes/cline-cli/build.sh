#!/usr/bin/env bash
set -exo pipefail

# Create package archive and install globally
pnpm pack --ignore-scripts
pnpm install -ddd \
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

tee ${PREFIX}/bin/cline << EOF
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/cline/dist/index.js" "$@"
EOF
chmod +x ${PREFIX}/bin/cline

tee ${PREFIX}/bin/cline.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\cline\dist\index.js %*
EOF
