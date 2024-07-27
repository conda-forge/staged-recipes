#!/usr/bin/env bash

# --- Function definitions ---

function reference_conda_packages() {
  local main_pkg=$1
  shift
  local pkgs=("$@")

  local licenses_filter="["
  local install_filter=()
  for pkg in "${pkgs[@]}"; do
    # Simulating the installation environment so that the relative path works
    (cd "${PREFIX}"/lib/node_modules && tar cf - "${pkg}" | (cd  "${SRC_DIR}" && tar xf -)) > /dev/null 2>&1
    # Install in devDepedencies to avoid adding unnecessary dependencies
    (cd "${SRC_DIR}"/"${main_pkg}" && pnpm install --save-dev "${pkg}@file:../${pkg}") > /dev/null 2>&1
    licenses_filter="${licenses_filter}\"!${pkg}\","
    install_filter+=("--filter" "\!${pkg}")
  done
  licenses_filter="${licenses_filter%,}"
  licenses_filter="${licenses_filter}]"

  echo "${licenses_filter}"
  echo "${install_filter[@]}"
}

function replace_null_versions() {
  local file_path=$1
  local new_version=$2

  # Read JSON file
  json_content=$(cat "$file_path")

  # Replace null values in versions
  modified_json=$(echo "$json_content" | jq --arg new_version "$new_version" '
    (.. | objects | select(has("versions")) | .versions) |= map(if . == null then $new_version else . end)
  ')

  # Write JSON file
  echo "$modified_json" > "$file_path"
}

set -euxo pipefail

# Don't use pre-built gyp packages
export npm_config_build_from_source=true
export npm_config_legacy_peer_deps=true
export NPM_CONFIG_USERCONFIG=/tmp/nonexistentrc
main_package="node-service-base-dev"
conda_packages=(
  "eslint" \
  "@typescript-eslint/eslint-plugin" \
  "@typescript-eslint/parser" \
)

if [[ ! -d "${SRC_DIR}"/"${main_package}" ]]; then
  echo "Error: Could not find the main package directory: ${SRC_DIR}/${main_package}"
  exit 1
fi

rm "${PREFIX}"/bin/node
ln -s "${BUILD_PREFIX}"/bin/node "${PREFIX}"/bin/node

filter_conda_packages=$(reference_conda_packages "${main_package}" "${conda_packages[@]}")
licenses_filter_conda_pkgs=$(echo "${filter_conda_packages}" | sed -n '1p')
install_filter_conda_pkgs=$(echo "${filter_conda_packages}" | sed -n '2p')

pushd ${main_package}
  rm -f package-lock.json

  # Build
  pnpm install
  rm -rf build && pnpm run compile
  # pnpm audit fix

  # Install
  eval pnpm install "${install_filter_conda_pkgs}"

  pnpm licenses list --prod --json > "${SRC_DIR}"/_conda-licenses.json
  replace_null_versions "${SRC_DIR}"/_conda-licenses.json "0.0.0" > /dev/null 2>&1
  pnpm-licenses generate-disclaimer \
    --prod \
    --filter="${licenses_filter_conda_pkgs}" \
    --json-input \
    --output-file="$SRC_DIR"/ThirdPartyLicenses.txt < "${SRC_DIR}"/_conda-licenses.json > "${SRC_DIR}"/_conda-licenses.txt 2>&1
  cp LICENSE "$SRC_DIR"/LICENSE

  pnpm pack

  npm install --global "dydxprotocol-${main_package}-${PKG_VERSION}.tgz"
popd
