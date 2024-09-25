#!/bin/sh

set -exuo pipefail

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi
# Don't use pre-built gyp packages
export npm_config_build_from_source=true

rm $PREFIX/bin/node
ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node

export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
pnpm import
pnpm install
pnpm pack
npm install -g speedscope-${PKG_VERSION}.tar.gz

# generate third party licenses file
pnpm licenses list --json --prod | pnpm-licenses generate-disclaimer --prod --json-input --output-file=third-party-licenses.txt