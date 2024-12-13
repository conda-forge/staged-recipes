#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    --prefix=${PREFIX}/libexec/${PKG_NAME} \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/srs-language-server << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/bin/node \${CONDA_PREFIX}/libexec/srs-language-server/bin/srs-language-server \$@
EOF
chmod +x ${PREFIX}/bin/srs-language-server

tee ${PREFIX}/bin/srs-language-server.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\libexec\srs-language-server\bin\srs-language-server %*
EOF
