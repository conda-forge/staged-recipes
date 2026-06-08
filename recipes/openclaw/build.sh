#!/usr/bin/env bash
set -exo pipefail

export SHARP_IGNORE_GLOBAL_LIBVIPS=1
export npm_config_sharp_ignore_global_libvips=true

sed -i.bak 's/^minimumReleaseAge: .*/minimumReleaseAge: 0/' pnpm-workspace.yaml

# Create license report for dependencies
mv package.json package.json.bak
jq 'del(.devDependencies)' package.json.bak > package.json
pnpm install --prod
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
mv package.json.bak package.json
rm -rf node_modules

# Build and pack the package
pnpm install
pnpm build
pnpm ui:build
pnpm pack --config.ignore-scripts=true

# Force sharp to use conda-forge libvips and build native binding locally
unset SHARP_IGNORE_GLOBAL_LIBVIPS
unset npm_config_sharp_ignore_global_libvips
export SHARP_FORCE_GLOBAL_LIBVIPS=1
export npm_config_sharp_build_from_source=true
export npm_config_sharp_force_global_libvips=true
export npm_config_build_from_source=true
export npm_config_node_gyp="${BUILD_PREFIX}/bin/node-gyp"
export NODE_PATH="${BUILD_PREFIX}/lib/node_modules:${NODE_PATH:-}"
export ESBUILD_BINARY_PATH="${BUILD_PREFIX}/bin/esbuild"
export PYTHON="${BUILD_PREFIX}/bin/python"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"
VIPS_CFLAGS="$(pkg-config --cflags vips-cpp)"
VIPS_LIBS="$(pkg-config --libs vips-cpp)"
export CPPFLAGS="${VIPS_CFLAGS} ${CPPFLAGS:-}"
export CXXFLAGS="${VIPS_CFLAGS} ${CXXFLAGS:-}"
export LDFLAGS="${VIPS_LIBS} ${LDFLAGS:-}"

npm install -ddd \
    --global \
    --prefix "${PREFIX}" \
    --build-from-source \
    ${PKG_NAME}-${PKG_VERSION}.tgz

# === Remove non-target platform binaries ===
NODE_MODULES="${PREFIX}/lib/node_modules/openclaw/node_modules"

case "$(uname -s)" in
    Linux)  OS="linux"  ;;
    Darwin) OS="darwin" ;;
esac
case "$(uname -m)" in
    x86_64)        ARCH="x64"   ;;
    aarch64|arm64) ARCH="arm64" ;;
esac

# Keep only the current platform's native binaries and remove foreign-platform prebuilds.
# koffi stores builds as OS_ARCH, while other prebuilds use OS-ARCH.
KEEP_UNDERSCORE="${OS}_${ARCH}"   # koffi: linux_x64, darwin_arm64
KEEP_DASH="${OS}-${ARCH}"         # prebuilds: linux-x64, darwin-arm64

echo "Pruning foreign binaries, keeping: ${KEEP_UNDERSCORE} / ${KEEP_DASH}"

# koffi was removed in 2026.5.26; guard for possible future re-addition
KOFFI_DIR="${NODE_MODULES}/koffi/build/koffi"
if [ -d "${KOFFI_DIR}" ]; then
    find "${KOFFI_DIR}" -mindepth 1 -maxdepth 1 -type d \
        ! -name "${KEEP_UNDERSCORE}" -exec rm -rf {} +
fi

# tree-sitter and the others
find "${NODE_MODULES}" -type d -name prebuilds | while read -r pb; do
    find "${pb}" -mindepth 1 -maxdepth 1 -type d \
        ! -name "${KEEP_DASH}" -exec rm -rf {} + 2>/dev/null
done

# sqlite-vec platform subpackages (no prebuilds dir)
find "${NODE_MODULES}" -mindepth 1 -maxdepth 1 -type d \
    -name "sqlite-vec-*" ! -name "sqlite-vec-${KEEP_DASH}" \
    -exec rm -rf {} +
