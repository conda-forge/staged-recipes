#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
pnpm install

# Create package archive and install globally
npm install
npm run compile
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --install-links \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/${PKG_NAME} << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/lib/node_modules/perl-debug-adapter/out/debugAdapter.js \$@
EOF

tee ${PREFIX}/bin/${PKG_NAME}.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\perl-debug-adapter\out\debugAdapter.js %*
EOF
