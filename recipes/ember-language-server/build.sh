#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch package.json to remove unneeded prepare step
mv package.json package.json.bak
jq 'del(.scripts.prepare)' package.json.bak > package.json

npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/ember-tooling-${PKG_NAME}-${PKG_VERSION}.tgz

# Patch package.json to remove resolutions key so pnpm-licenses
# can be run to generate license report
mv package.json package.json.bak
jq 'del(.resolutions)' package.json.bak > package.json

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/ember-language-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\bin\ember-language-server %*
EOF
