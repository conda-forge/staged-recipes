#!/bin/sh

set -exuo pipefail

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi
# Don't use pre-built gyp packages
export npm_config_build_from_source=true

cp -r shared python/interpret-core/symbolic/shared

npm install --package-lock-only --ignore-scripts && npx force-resolutions

cd python/interpret-core && {{ PYTHON }} setup.py build && {{ PYTHON }} setup.py install

rm $PREFIX/bin/node
ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node

yarn pack
yarn licenses generate-disclaimer --prod > ThirdPartyLicenses.txt
NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

npm install -g ${PKG_NAME}-v${PKG_VERSION}.tgz


