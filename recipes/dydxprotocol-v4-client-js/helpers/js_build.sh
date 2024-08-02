# --- Function definitions ---

function analyze_dependencies() {
  local package_json_path=$1

  if [[ ! -f "$package_json_path" ]]; then
    echo "Error: $package_json_path does not exist."
    exit 1
  fi

  while IFS= read -r line; do
    dep+=("$line")
  done < <(jq -r '.dependencies // {} | keys[]' "$package_json_path")

  while IFS= read -r line; do
    dev+=("$line")
  done < <(jq -r '.devDependencies // {} | keys[]' "$package_json_path")

  declare -g dependencies=("${dep[@]:-()}")
  declare -g devDependencies=("${dev[@]:-()}")
}

function reference_conda_packages() {
  local main_pkg=$1
  shift
  local pkgs=("$@")

  licenses_filter="["
  install_filter=()

  (cd "${BUILD_PREFIX}"/lib/node_modules && tar cf - . | (cd  "${SRC_DIR}" && tar xf -)) > /dev/null 2>&1
  (cd "${PREFIX}"/lib/node_modules && tar cf - . | (cd  "${SRC_DIR}" && tar xf -)) > /dev/null 2>&1

  for pkg in "${pkgs[@]}"; do
    mkdir -p "${SRC_DIR}"/_conda-logs

    set +x
    rpath=".." # Default relative path
    for ((i=0; i<${#main_pkg}; i++)); do
      if [[ "${main_pkg:$i:1}" == "/" ]]; then
        rpath="${rpath}/.."
      fi
    done
    set -x

    if [[ " ${dependencies[*]} " == *" ${pkg} "* ]]; then
      (cd "${SRC_DIR}"/"${main_pkg}" && pnpm install --save "${pkg}@file:${rpath}/${pkg}") > "${SRC_DIR}"/_conda-logs/dep.log 2>&1
    elif [[ " ${devDependencies[*]} " == *" ${pkg} "* ]]; then
      (cd "${SRC_DIR}"/"${main_pkg}" && pnpm install --save-dev "${pkg}@file:${rpath}/${pkg}") > "${SRC_DIR}"/_conda-logs/dev.log 2>&1
    else
      echo "${pkg} is not found in dependencies or devDependencies" >&2
    fi

    licenses_filter="${licenses_filter}\"!${pkg}\","
    install_filter+=("--filter" "!${pkg}")
  done
  licenses_filter="${licenses_filter%,}"

  declare -g licenses_filter_conda_pkgs="${licenses_filter}]"
  declare -g install_filter_conda_pkgs=("${install_filter[@]}")
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

function third_party_licenses() {
  local main_pkg=$1

  pushd "${main_pkg}" || exit 1
    mkdir -p "${SRC_DIR}"/_conda-logs

    pnpm licenses list --prod --json > "${SRC_DIR}"/_conda-licenses.json
    replace_null_versions "${SRC_DIR}"/_conda-licenses.json "0.0.0" > "${SRC_DIR}"/_conda-logs/replace_null.log 2>&1
    pnpm-licenses generate-disclaimer \
      --prod \
      --filter="${licenses_filter_conda_pkgs}" \
      --json-input \
      --output-file="$SRC_DIR"/ThirdPartyLicenses.txt < "${SRC_DIR}"/_conda-licenses.json > "${SRC_DIR}"/_conda-logs/licenses.log 2>&1
  popd || exit 1
}
