#!/bin/bash

set -ex

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi

rm $PREFIX/bin/node
ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node

yarn pack
yarn licenses generate-disclaimer > ThirdPartyLicenses.txt
NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

npm install -g ${PKG_NAME}-v${PKG_VERSION}.tgz
