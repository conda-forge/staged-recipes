#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    google-${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

tee ${PREFIX}/bin/gemini << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/@google/gemini-cli/dist/index.js %*
EOF
chmod +x ${PREFIX}/bin/gemini

tee ${PREFIX}/bin/gemini.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\@google\gemini-cli\dist\index.js %*
EOF
