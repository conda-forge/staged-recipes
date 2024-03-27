# #!/usr/bin/env bash
#
# Conda-forge recommended build
set -euxo pipefail

if [[ "${target_platform}" == "osx-arm64" ]]; then
    export npm_config_arch="arm64"
fi

export npm_config_build_from_source=true

rm $PREFIX/bin/node
ln -s $BUILD_PREFIX/bin/node $PREFIX/bin/node

NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

cd v4-client-js
rm -rf node_modules package-lock.json
pnpm install typescript rollup

pnpm run build
tgz=$(pnpm pack)
npm install ${tgz}
pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file=ThirdPartyLicenses.txt

# Passing build
# cd v4-client-js
# npm install rollup
# npm run build
# npm test
# tgz=$(npm pack)
# npm install --prefix $PREFIX -g $tgz
#
# # Install in share directory
# mkdir -p $PREFIX/share
# mv $PREFIX/lib/node_modules/@dydxprotocol $PREFIX/share/@dydxprotocol
# ln -s $PREFIX/share/@dydxprotocol $PREFIX/lib/node_modules/@dydxprotocol
# echo "$PKG_VERSION" > $PREFIX/share/@dydxprotocol/v4-client-js/version
