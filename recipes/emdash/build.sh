#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail -o xtrace

case "${target_platform}" in
  linux-64)
    electron_platform="linux"
    electron_arch="x64"
    ;;
  osx-64)
    electron_platform="mac"
    electron_arch="x64"
    ;;
  osx-arm64)
    electron_platform="mac"
    electron_arch="arm64"
    ;;
  *)
    echo "Unsupported target platform: ${target_platform}" >&2
    exit 1
    ;;
esac

export CI=1
export EMDASH_SKIP_ELECTRON_REBUILD=1
export npm_config_build_from_source=true
export npm_config_manage_package_manager_versions=false

pnpm config set manage-package-manager-versions false
pnpm install --frozen-lockfile
pnpm run build

pnpm --filter @emdash/emdash-desktop licenses list --json --prod \
  > third-party-licenses.json
node "${RECIPE_DIR}/generate-third-party-licenses.mjs" \
  third-party-licenses.json \
  third-party-licenses.txt \
  node_modules/electron/dist/LICENSE \
  node_modules/electron/dist/LICENSES.chromium.html
test "$(wc -c < third-party-licenses.txt)" -gt 10000

deploy_dir="${SRC_DIR}/.emdash-conda-deploy"
mkdir -p "${deploy_dir}"
pnpm --filter @emdash/emdash-desktop deploy --legacy --prod "${deploy_dir}"
cp -R apps/emdash-desktop/out "${deploy_dir}/out"
cp -R apps/emdash-desktop/drizzle "${deploy_dir}/drizzle"
mkdir -p "${deploy_dir}/icons"
cp apps/emdash-desktop/src/assets/images/emdash/emdash.icns "${deploy_dir}/icons/emdash.icns"
cp apps/emdash-desktop/src/assets/images/emdash/emdash.png "${deploy_dir}/icons/emdash.png"

node --experimental-strip-types \
  apps/emdash-desktop/scripts/release/rebuild-native.ts \
  --arch "${electron_arch}" \
  --deploy-dir "${deploy_dir}"

electron_version="$(node -p "require('./node_modules/electron/package.json').version")"
pnpm --dir apps/emdash-desktop exec electron-builder \
  "--${electron_platform}" \
  --dir \
  "--${electron_arch}" \
  --publish never \
  --projectDir "${deploy_dir}" \
  --config "${RECIPE_DIR}/electron-builder.json" \
  --config.electronVersion="${electron_version}" \
  --config.electronDist="${SRC_DIR}/node_modules/electron/dist"

mkdir -p "${PREFIX}/bin"

if [[ "${electron_platform}" == "linux" ]]; then
  test -d "${deploy_dir}/release/linux-unpacked"
  mkdir -p "${PREFIX}/libexec"
  cp -R "${deploy_dir}/release/linux-unpacked" "${PREFIX}/libexec/emdash"
  ln -s ../libexec/emdash/emdash "${PREFIX}/bin/emdash"
else
  app_bundles=("${deploy_dir}"/release/mac*/Emdash.app)
  test "${#app_bundles[@]}" -eq 1
  codesign --force --deep --sign - --timestamp=none "${app_bundles[0]}"
  mkdir -p "${PREFIX}/Applications"
  cp -R "${app_bundles[0]}" "${PREFIX}/Applications/Emdash.app"
  ln -s ../Applications/Emdash.app/Contents/MacOS/emdash "${PREFIX}/bin/emdash"
fi
