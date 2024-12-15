#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/vercel-${PKG_VERSION}.tgz

# Patch package.json to remove devDependencies so that
# pnpm-licenses can be run to create license report
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/vercel-cli.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\vercel-cli %*
EOF

# Delete vendored esbuild so package is noarch
rm -rf ${PREFIX}/lib/node_modules/blitz/node_modules/esbuild
rm -rf ${PREFIX}/lib/node_modules/blitz/node_modules/esbuild-linux-64
