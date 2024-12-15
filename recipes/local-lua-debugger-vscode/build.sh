#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Install devDependencies and transpile TypeScript to JavaScript
npm install
npm run build
mkdir -p dist
cp -r extension/*.js dist

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --install-links \
    ${PKG_NAME}-${PKG_VERSION}.tgz
cp -r debugger/*.lua ${PREFIX}/lib/node_modules/${PKG_NAME}/debugger

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/local-lua-dbg << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/lib/node_modules/local-lua-debugger-vscode/dist/debugAdapter.js \$@
EOF

tee ${PREFIX}/bin/local-lua-dbg.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\local-lua-debugger-vscode\dist\debugAdapter.js %*
EOF
