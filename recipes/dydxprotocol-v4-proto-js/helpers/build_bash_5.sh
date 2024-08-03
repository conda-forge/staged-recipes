#!/usr/bin/env bash

set -euxo pipefail

source "${RECIPE_DIR}"/helpers/js_build.sh

# Don't use pre-built gyp packages
export npm_config_build_from_source=true
export npm_config_legacy_peer_deps=true
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

mkdir -p "${SRC_DIR}"/_conda-logs

# Defines the module name once installed in node_modules
main_package="@dydxprotocol/v4-proto"

rm "${PREFIX}"/bin/node
ln -s "${BUILD_PREFIX}"/bin/node "${PREFIX}"/bin/node

pushd "${SRC_DIR}/js_module_source/v4-proto-js"
  pnpm install --save @cosmjs/tendermint-rpc
  pnpm install --save-dev @types/node @types/long@4.0.2
  pnpm run transpile
  if [[ "$(uname)" == "Darwin" ]]; then
    find "src/codegen" -name "*.ts" -exec sed -i '' 's/\(e\) =>/(\1: any) =>/g' {} \;
  else
    find "src/codegen" -name "*.ts" -exec sed -i 's/\(e\) =>/(\1: any) =>/g' {} \;
  fi
popd

mkdir -p "${SRC_DIR}/${main_package}"
(cd "${SRC_DIR}/js_module_source/v4-proto-js" && tar cf - . | (cd "${SRC_DIR}/${main_package}" && tar xf -))
pushd "${SRC_DIR}/${main_package}"
  # Patch version
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/0.0.0/${PKG_VERSION}/g" package.json
  else
    sed -i "s/0.0.0/${PKG_VERSION}/g" package.json
  fi

  pnpm tsc --project ./tsconfig.json --traceResolution > "${SRC_DIR}"/_conda-logs/tsc.log 2>&1
  pnpm install

  third_party_licenses "${SRC_DIR}"/${main_package}
  cp LICENSE "$SRC_DIR"/LICENSE

  pnpm pack
popd
