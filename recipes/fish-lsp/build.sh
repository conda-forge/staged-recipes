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

# Fix package.json so it can bootstrap itself
# Remove prepare script because it tries to call husky
# Remove compile command from post install script so we don't try to transpile typescript again
mv package.json package.json.bak
jq 'del(.scripts.prepare)' package.json.bak > package.json
sed -i 's/setup compile sh:relink/setup sh:relink/' package.json

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION//_/-}.tgz

# Create license report for dependencies
pnpm install --ignore-scripts
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt

rm -rf ${PREFIX}/lib/node_modules/fish-lsp/node_modules/tree-sitter/build
