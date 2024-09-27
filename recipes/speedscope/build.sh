#!/bin/sh

set -exuo pipefail

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi
# Don't use pre-built gyp packages
export npm_config_build_from_source=true

rm $PREFIX/bin/node
ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node

# install speedscope from the npm registry
# all things coming after this are just concerned with generating the third-party-licenses file
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
npm install -g speedscope@${PKG_VERSION}

pnpm import
pnpm install --prod

# generate third party licenses file
pnpm licenses list --json --prod | pnpm-licenses generate-disclaimer --prod --json-input --output-file=third-party-licenses.txt