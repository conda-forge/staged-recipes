set -euxo pipefail

source "${RECIPE_DIR}"/helpers/js_build.sh

# Don't use pre-built gyp packages
export npm_config_build_from_source=true
export npm_config_legacy_peer_deps=true
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc

# Defines the module name once installed in node_modules
main_package="@dydxprotocol/v4-client-js"
conda_packages=(
  "@dydxprotocol/v4-proto" \
  "@typescript-eslint/eslint-plugin" \
  "@typescript-eslint/parser" \
  "eslint-config-prettier" \
  "prettier" \
)

mkdir -p "${SRC_DIR}/${main_package}"
(cd "${SRC_DIR}/js_module_source/v4-client-js" && tar cf - . | (cd "${SRC_DIR}/${main_package}" && tar xf -))

rm "${PREFIX}"/bin/node
ln -s "${BUILD_PREFIX}"/bin/node "${PREFIX}"/bin/node

analyze_dependencies "${SRC_DIR}/${main_package}/package.json"
reference_conda_packages "${main_package}" "${conda_packages[@]}"

pushd "${SRC_DIR}/${main_package}" || exit 1
  # rm -f package-lock.json pnpm-lock.yaml

  # pnpm install --save-dev typescript@latest @types/jest @types/node @types/long
  pnpm install

  pnpm run transpile

  if [[ "$(uname)" == "Darwin" ]]; then
    find "src/codegen" -name "*.ts" -exec sed -i '' 's/\(e\) =>/(\1: any) =>/g' {} \;
  else
    find "src/codegen" -name "*.ts" -exec sed -i 's/\(e\) =>/(\1: any) =>/g' {} \;
  fi
  pnpm run compile
  pnpm run test

  # Install
  eval pnpm install "${install_filter_conda_pkgs}"

  third_party_licenses "${SRC_DIR}"/${main_package}
  cp LICENSE "$SRC_DIR"/LICENSE

  pnpm pack
popd
