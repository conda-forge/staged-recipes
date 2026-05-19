#!/usr/bin/env bash
set -exo pipefail

# Force sharp to use conda-forge libvips and build native binding locally
export npm_config_build_from_source=true
export npm_config_sharp_build_from_source=true
export npm_config_sharp_force_global_libvips=true
export npm_config_node_gyp="${BUILD_PREFIX}/bin/node-gyp"
export ESBUILD_BINARY_PATH="${BUILD_PREFIX}/bin/esbuild"
export SHARP_FORCE_GLOBAL_LIBVIPS=1
export PYTHON="${BUILD_PREFIX}/bin/python"

pkg-config --modversion vips-cpp
sed -i.bak 's/^minimumReleaseAge: .*/minimumReleaseAge: 0/' pnpm-workspace.yaml

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json
pnpm install --prod
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
mv package.json.bak package.json

# Build and pack the package to install it
rm -rf node_modules
pnpm install
pnpm build
pnpm ui:build
pnpm pack --config.ignore-scripts=true
npm install -ddd \
    --global \
    --prefix "${PREFIX}" \
    --build-from-source \
    --foreground-scripts \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# Build sharp from source
pushd "${PREFIX}/lib/node_modules/openclaw"
npm install --ignore-scripts node-addon-api
npm install \
    --foreground-scripts \
    --build-from-source \
    --ignore-scripts=false \
    sharp
popd

# Remove prebuilt native binaries for non-target platforms.
# This avoids packaging unrelated .node files such as FreeBSD/OpenBSD/musl/arm/riscv builds.
case "${target_platform}" in
  linux-64)
    koffi_platform="linux_x64"
    tree_sitter_platform="linux-x64"
    ;;
  linux-aarch64)
    koffi_platform="linux_arm64"
    tree_sitter_platform="linux-arm64"
    ;;
  linux-ppc64le)
    koffi_platform="linux_ppc64le"
    tree_sitter_platform="linux-ppc64le"
    ;;
  osx-64)
    koffi_platform="macos_x64"
    tree_sitter_platform="darwin-x64"
    ;;
  osx-arm64)
    koffi_platform="macos_arm64"
    tree_sitter_platform="darwin-arm64"
    ;;
  win-64)
    koffi_platform="win32_x64"
    tree_sitter_platform="win32-x64"
    ;;
  win-arm64)
    koffi_platform="win32_arm64"
    tree_sitter_platform="win32-arm64"
    ;;
  *)
    echo "Unknown target_platform: ${target_platform}"
    exit 1
    ;;
esac

koffi_dir="${PREFIX}/lib/node_modules/openclaw/node_modules/koffi/build/koffi"
if [ -d "${koffi_dir}" ]; then
  find "${koffi_dir}" \
    -mindepth 1 -maxdepth 1 -type d ! -name "${koffi_platform}" \
    -exec rm -rf {} +
fi

tree_sitter_dir="${PREFIX}/lib/node_modules/openclaw/node_modules/tree-sitter-bash/prebuilds"
if [ -d "${tree_sitter_dir}" ]; then
  find "${tree_sitter_dir}" \
    -mindepth 1 -maxdepth 1 -type d ! -name "${tree_sitter_platform}" \
    -exec rm -rf {} +
fi
