set -euxo pipefail

source "${RECIPE_DIR}"/helpers/js_build.sh

# Don't use pre-built gyp packages
export npm_config_build_from_source=true
export npm_config_legacy_peer_deps=true
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

# Defines the module name once installed in node_modules
main_package="@dydxprotocol/v4-client-js"

mkdir -p "${SRC_DIR}/${main_package}"
(cd "${SRC_DIR}/js_module_source/v4-client-js" && tar cf - . | (cd "${SRC_DIR}/${main_package}" && tar xf -))

rm "${PREFIX}"/bin/node
ln -s "${BUILD_PREFIX}"/bin/node "${PREFIX}"/bin/node

pushd "${SRC_DIR}/${main_package}" || exit 1
  pnpm remove grpc-tools
  pnpm install --save-dev @grpc/grpc-js typescript@4.8.4 @types/jest @types/long@4.0.2 @types/node@18.15.13 @types/lodash @cosmjs/crypto
  pnpm install

  pnpm run transpile

  if [[ "$(uname)" == "Darwin" ]]; then
    find src/codegen node_modules -name "*.ts" -exec sed -i '' 's/\(e\) =>/(\1: any) =>/g' {} \;
  else
    find src/codegen node_modules -name "*.ts" -exec sed -i 's/\(e\) =>/(\1: any) =>/g' {} \;
  fi
  pnpm run compile
  pnpm install --save-dev jest
  NODE_ENV=test pnpm exec jest --testPathIgnorePatterns=__tests__/modules/client/*

  # Install
  pnpm install

  third_party_licenses "${SRC_DIR}"/${main_package}
  cp LICENSE "$SRC_DIR"/LICENSE

  pnpm pack
popd
