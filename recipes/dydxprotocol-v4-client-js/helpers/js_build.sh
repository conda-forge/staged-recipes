# --- Function definitions ---

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
      --json-input \
      --output-file="$SRC_DIR"/ThirdPartyLicenses.txt < "${SRC_DIR}"/_conda-licenses.json > "${SRC_DIR}"/_conda-logs/licenses.log 2>&1
  popd || exit 1
}
