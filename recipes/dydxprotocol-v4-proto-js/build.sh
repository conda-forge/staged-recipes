#!/usr/bin/env bash

set -euxo pipefail

ls -lrt "helpers"
ls -lrt "${RECIPE_DIR}"
ls -lrt "${RECIPE_DIR}/helpers"
ls -lrt "${RECIPE_DIR}/helpers/js_build.sh"
source "${RECIPE_DIR}"/helpers/js_build.sh

# Don't use pre-built gyp packages
export npm_config_build_from_source=true
export npm_config_legacy_peer_deps=true
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

# Defines the module name once installed in node_modules
main_package="@dydxprotocol/v4-proto"
conda_packages=(
  "@dydxprotocol/node-service-base-dev" \
  "@typescript-eslint/eslint-plugin" \
  "@typescript-eslint/parser" \
)

mkdir -p "${SRC_DIR}/${main_package}"
(cd "${SRC_DIR}/js_module_source" && tar cf - . | (cd "${SRC_DIR}/@dydxprotocol" && tar xf -))
(cd "${SRC_DIR}/@dydxprotocol/v4-proto-js" && tar cf - . | (cd "${SRC_DIR}/${main_package}" && tar xf -))

rm "${PREFIX}"/bin/node
ln -s "${BUILD_PREFIX}"/bin/node "${PREFIX}"/bin/node

analyze_dependencies "${SRC_DIR}/${main_package}/package.json"
reference_conda_packages "${main_package}" "${conda_packages[@]}"

pushd ${main_package}
  # Patch version
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/0.0.0/${PKG_VERSION}/g" package.json
  else
    sed -i "s/0.0.0/${PKG_VERSION}/g" package.json
  fi

  rm -f package-lock.json

  pnpm install --save @cosmjs/tendermint-rpc
  pnpm install --save-dev long@latest typescript@latest @types/node

  # pnpm import
  pnpm install
  pnpm run transpile

  if [[ "$(uname)" == "Darwin" ]]; then
    find "src/codegen" -name "*.ts" -exec sed -i '' 's/\(e\) =>/(\1: any) =>/g' {} \;
  else
    find "src/codegen" -name "*.ts" -exec sed -i 's/\(e\) =>/(\1: any) =>/g' {} \;
  fi
  pnpm run build

  # Install
  eval pnpm install "${install_filter_conda_pkgs}"

  third_party_licenses "${SRC_DIR}"/${main_package}
  cp LICENSE "$SRC_DIR"/LICENSE

  pnpm pack
popd
