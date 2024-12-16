#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Install devDependencies and transpile TypeScript to JavaScript
npm install
npm run compile

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --install-links \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

# Delete broken wrapper
rm ${PREFIX}/bin/perl-debug-adapter

tee ${PREFIX}/bin/perl-debug-adapter << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/lib/node_modules/perl-debug-adapter/out/debugAdapter.js \$@
EOF

tee ${PREFIX}/bin/perl-debug-adapter.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\perl-debug-adapter\out\debugAdapter.js %*
EOF
