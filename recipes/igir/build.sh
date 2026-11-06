#!/usr/bin/env bash

set -euxo pipefail

# Ignore any global/user npm & pnpm configuration on the CI host.
export NPM_CONFIG_USERCONFIG="${SRC_DIR}/nonexistent-userrc"
export NPM_CONFIG_GLOBALCONFIG="${SRC_DIR}/nonexistent-globalrc"
export npm_config_minimum_release_age=0

# Install the pre-built npm package (compiled JS + prebuilt Node-API addons)
# into $PREFIX/lib/node_modules/igir with a launcher in $PREFIX/bin.
npm install -g "${SRC_DIR}/igir-${PKG_VERSION}.tgz"

# Only keep the prebuilt native addons for the target platform. igir falls
# back to the bundled WASM builds if a native addon cannot be loaded.
case "${target_platform}" in
  linux-64) keep="linux-x64" ;;
  linux-aarch64) keep="linux-arm64" ;;
  osx-64) keep="darwin-x64" ;;
  osx-arm64) keep="darwin-arm64" ;;
  *) keep="" ;;
esac
for dir in "${PREFIX}"/lib/node_modules/igir/dist/addons/*/addon-*/prebuilds/*; do
  if [[ "$(basename "${dir}")" != "${keep}" ]]; then
    rm -rf "${dir}"
  fi
done

# Generate ThirdPartyLicenses.txt for the bundled npm dependencies from the
# upstream lock file.
pnpm import
pnpm install --prod --ignore-scripts
pnpm licenses list --json --prod | pnpm-licenses generate-disclaimer --json-input --output-file=ThirdPartyLicenses.txt
