#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include/glib-2.0 -I${PREFIX}/lib/glib-2.0/include"

# Create package archive and install globally
if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi

if [[ "${build_platform}" != "${target_platform}" ]]; then
    rm $PREFIX/bin/node
    ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node
fi

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
