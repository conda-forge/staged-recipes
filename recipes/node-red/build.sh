#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi

if [[ "${build_platform}" != "${target_platform}" ]]; then
    rm $PREFIX/bin/node
    ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node
fi

npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

# Create license report for dependencies
pnpm install
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

mkdir -p ${PREFIX}/share/${PKG_NAME}
install -m 644 ${RECIPE_DIR}/service.yaml ${PREFIX}/share/${PKG_NAME}
