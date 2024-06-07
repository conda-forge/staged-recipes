#!/usr/bin/env bash

set -euxo pipefail

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi

# Don't use pre-built gyp packages
export npm_config_build_from_source=true

rm $PREFIX/bin/node
ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node

NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

# install playwright globally from the npm registry
# all things coming after this are just concerned with generating the ThirdPartyLicenses.txt file
npm install -g ${PKG_NAME}@${PKG_VERSION}

pnpm import
pnpm install --prod
pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file=ThirdPartyLicenses.txt
