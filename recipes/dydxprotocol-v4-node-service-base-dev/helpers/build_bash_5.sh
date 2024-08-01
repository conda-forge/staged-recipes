set -euxo pipefail

source "${RECIPE_DIR}"/helpers/js_build.sh

# Don't use pre-built gyp packages
export npm_config_build_from_source=true
export npm_config_legacy_peer_deps=true
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
# Defines the module name once installed
main_package="@dydxprotocol/node-service-base-dev"
conda_packages=(
  "eslint" \
  "@typescript-eslint/eslint-plugin" \
  "@typescript-eslint/parser" \
)

mkdir -p "${SRC_DIR}/${main_package}"
(cd "${SRC_DIR}/js_module_source" && tar cf - .) | (cd "${SRC_DIR}/${main_package}" && tar xf -)

rm "${PREFIX}"/bin/node
ln -s "${BUILD_PREFIX}"/bin/node "${PREFIX}"/bin/node

install_filter_conda_pkgs=()
analyze_dependencies ${main_package}/package.json
reference_conda_packages "${main_package}" "${conda_packages[@]}"

pushd "${SRC_DIR}/${main_package}"
  # rm -f package-lock.json

  # Build
  pnpm install
  rm -rf build && pnpm run compile
  # pnpm audit fix

  # Install
  eval pnpm install "${install_filter_conda_pkgs[*]}"

  third_party_licenses "${SRC_DIR}"/${main_package}
  cp LICENSE "$SRC_DIR"/LICENSE

  pnpm pack

  npm install --omit=dev --global "${PKG_NAME}-${PKG_VERSION}.tgz"
popd
