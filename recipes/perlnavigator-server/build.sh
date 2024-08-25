#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
pnpm install

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/perlnavigator << EOF
#!/bin/sh
exec node \${CONDA_PREFIX}/lib/node_modules/perlnavigator-server/out/server.js "\$@"
EOF

tee ${PREFIX}/bin/perlnavigator.cmd << EOF
call node %CONDA_PREFIX%\lib\node_modules\perlnavigator-server\out\server.js %* 
EOF
