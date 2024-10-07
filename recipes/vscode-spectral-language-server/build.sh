#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i 's/commonjs/nodenext/' tsconfig.base.json

npm install
npm install @rollup/plugin-commonjs
npm install @rollup/pluginutils

cd server
npm install
tsc
mv dist/src out

npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --install-links \
    server-0.0.1.tgz
mv ${PREFIX}/lib/node_modules/server ${PREFIX}/lib/node_modules/${PKG_NAME}

tee ${PREFIX}/bin/spectral-language-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/lib/node_modules/vscode-spectral-language-server/out/server.js
EOF
