#!/usr/bin/env bash
#
# Conda-forge recommended build recipe
set -euxo pipefail

# Don't use pre-built gyp packages
export npm_config_build_from_source=true

# rm "$PREFIX"/bin/node
# ln -s "$BUILD_PREFIX"/bin/node "$PREFIX"/bin/node

NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

pushd v4-proto-js
  pnpm install
  pnpm pack
  pnpm licenses list --json | pnpm-licenses generate-disclaimer --json-input --output-file="$SRC_DIR"/ThirdPartyLicenses.txt

  npm install -g "dydxprotocol-v4-proto-${PKG_VERSION}.tgz"
popd
