#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Run pnpm so that pnpm-licenses can create report
cd extension
pnpm install

# Create package archive and install globally
npm install
npm run compile
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --install-links \
    go-${PKG_VERSION}.tgz

# Create license report for dependencies
mv pnpm-lock.yaml pnpm-lock.yaml.bak
yq 'del(.importers.[].dependencies.tree-kill)' pnpm-lock.yaml.bak > pnpm-lock.yaml
pnpm-licenses generate-disclaimer --prod --output-file=${SRC_DIR}/third-party-licenses.txt

tee ${PREFIX}/bin/vscode-go-debug-adapter << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/lib/node_modules/go/dist/debugAdapter.js \$@
EOF

tee ${PREFIX}/bin/vscode-go-debug-adapter.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\go\dist\debugAdapter.js %*
EOF
