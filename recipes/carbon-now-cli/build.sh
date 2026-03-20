#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# Strip lifecycle scripts that interfere with packaging (husky, playwright)
mv package.json package.json.bak
jq 'del(.scripts.prepare, .scripts.postinstall)' package.json.bak > package.json

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    --ignore-scripts \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json

pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/carbon-now << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/carbon-now-cli/bundle/cli.js "\$@"
EOF
chmod +x ${PREFIX}/bin/carbon-now

tee ${PREFIX}/bin/carbon-now.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\carbon-now-cli\bundle\cli.js %*
EOF
