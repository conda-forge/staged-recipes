#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch tsconfig to use correct node version
sed -i 's/commonjs/nodenext/' tsconfig.base.json

# Install some build dependencies
npm install
npm install @rollup/plugin-commonjs
npm install @rollup/pluginutils
npm install typescript
npm install @types/node

# Transpile typescript to javascript
cd server
npm install
npx tsc
mv dist/src out

# Install package globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --install-links \
    server-0.0.1.tgz
mv ${PREFIX}/lib/node_modules/server ${PREFIX}/lib/node_modules/${PKG_NAME}

# Create bash and batch wrappers
mkdir -p ${PREFIX}//bin
tee ${PREFIX}/bin/spectral-language-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/lib/node_modules/vscode-spectral-language-server/out/server.js \$@
EOF
chmod +x ${PREFIX}/bin/spectral-language-server

tee ${PREFIX}/bin/spectral-language-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\vscode-spectral-language-server\out\server.js %*
EOF
