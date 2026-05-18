#!/usr/bin/env bash
set -exo pipefail

# Install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Create wrapper scripts
tee ${PREFIX}/bin/repomix << 'EOF'
#!/bin/sh
exec "${CONDA_PREFIX}/bin/node" "${CONDA_PREFIX}/lib/node_modules/repomix/dist/index.js" "$@"
EOF
chmod +x ${PREFIX}/bin/repomix

tee ${PREFIX}/bin/repomix.cmd << 'EOF'
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\repomix\dist\index.js %*
EOF
